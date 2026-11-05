// Events: the city listing. Built from Notes.cs, the template entity.
//
// Unlike notes, events are not private: every signed in user sees the whole
// listing. Only the user who created an event may change or delete it.

using System.Globalization;
using Microsoft.Data.Sqlite;

namespace PamBackend;

public record Event(
    long Id,
    long OwnerId,
    string Title,
    string Category,
    string Venue,
    string StartsAt,
    double Price,
    string ImageUrl,
    string Description,
    string CreatedAt);

public record EventInput(
    string? Title,
    string? Category,
    string? Venue,
    string? StartsAt,
    double? Price,
    string? ImageUrl,
    string? Description);

public static class Events
{
    /// <summary>Categories from the specification; the app filters by these values.</summary>
    public static readonly string[] Categories =
        ["концерт", "стендап", "выставка", "хакатон", "вечеринка"];

    private const string Columns =
        "id, user_id, title, category, venue, starts_at, price, image_url, description, created_at";

    private static Event ReadEvent(SqliteDataReader r) => new(
        r.GetInt64(0), r.GetInt64(1), r.GetString(2), r.GetString(3), r.GetString(4),
        r.GetString(5), r.GetDouble(6), r.GetString(7), r.GetString(8), r.GetString(9));

    public static Event? Find(SqliteConnection conn, long id)
    {
        using var cmd = conn.Cmd($"SELECT {Columns} FROM events WHERE id = $id", ("$id", id));
        using var reader = cmd.ExecuteReader();
        return reader.Read() ? ReadEvent(reader) : null;
    }

    /// <summary>
    /// GET /events?page=1&amp;limit=20&amp;search=&amp;category=
    ///   -> {items, page, limit, total}, sorted by start time.
    /// </summary>
    public static IResult List(int page = 1, int limit = 20, string search = "", string category = "")
    {
        page = Math.Max(page, 1);
        limit = Math.Clamp(limit, 1, 100);

        // SQLite's LIKE ignores case for Latin letters only, so "хакатон" would
        // miss "Хакатон". Both sides go through .NET lowercasing instead.
        const string where =
            "ulower(title) LIKE $pattern AND ($category = '' OR category = $category)";
        var pattern = $"%{search.ToLowerInvariant()}%";

        using var conn = Db.Open();
        conn.CreateFunction("ulower", (string value) => value.ToLowerInvariant());
        long total;
        using (var count = conn.Cmd($"SELECT COUNT(*) FROM events WHERE {where}",
                   ("$pattern", pattern), ("$category", category)))
        {
            total = (long)count.ExecuteScalar()!;
        }

        var items = new List<Event>();
        using var cmd = conn.Cmd(
            $"SELECT {Columns} FROM events WHERE {where} " +
            "ORDER BY starts_at, id LIMIT $limit OFFSET $offset",
            ("$pattern", pattern), ("$category", category),
            ("$limit", limit), ("$offset", (page - 1) * limit));
        using var reader = cmd.ExecuteReader();
        while (reader.Read()) items.Add(ReadEvent(reader));

        return Results.Json(new { items, page, limit, total });
    }

    /// <summary>GET /events/{id} -> 200 event | 404</summary>
    public static IResult GetOne(long id)
    {
        using var conn = Db.Open();
        var ev = Find(conn, id);
        return ev is null ? Errors.NotFound("Event not found") : Results.Json(ev);
    }

    /// <summary>POST /events {title, category, venue, startsAt, price, imageUrl, description} -> 201 event</summary>
    public static IResult Create(HttpContext context, EventInput input)
    {
        var (fields, error) = Validate(input);
        if (error is not null) return error;

        using var conn = Db.Open();
        using (var insert = conn.Cmd(
                   "INSERT INTO events (user_id, title, category, venue, starts_at, price, " +
                   "image_url, description, created_at) VALUES ($userId, $title, $category, " +
                   "$venue, $startsAt, $price, $imageUrl, $description, $createdAt)",
                   ("$userId", Auth.CurrentUserId(context)), ("$title", fields!.Title),
                   ("$category", fields.Category), ("$venue", fields.Venue),
                   ("$startsAt", fields.StartsAt), ("$price", fields.Price),
                   ("$imageUrl", fields.ImageUrl), ("$description", fields.Description),
                   ("$createdAt", Db.NowIso())))
        {
            insert.ExecuteNonQuery();
        }
        var ev = Find(conn, conn.LastInsertRowId())!;
        return Results.Created($"/events/{ev.Id}", ev);
    }

    /// <summary>PUT /events/{id} -> 200 updated event | 403 not the owner | 404</summary>
    public static IResult Update(HttpContext context, long id, EventInput input)
    {
        using var conn = Db.Open();
        var existing = Find(conn, id);
        if (existing is null) return Errors.NotFound("Event not found");
        if (existing.OwnerId != Auth.CurrentUserId(context))
            return Errors.Forbidden("Only the organizer can change the event");

        var (fields, error) = Validate(input);
        if (error is not null) return error;

        using (var update = conn.Cmd(
                   "UPDATE events SET title = $title, category = $category, venue = $venue, " +
                   "starts_at = $startsAt, price = $price, image_url = $imageUrl, " +
                   "description = $description WHERE id = $id",
                   ("$title", fields!.Title), ("$category", fields.Category),
                   ("$venue", fields.Venue), ("$startsAt", fields.StartsAt),
                   ("$price", fields.Price), ("$imageUrl", fields.ImageUrl),
                   ("$description", fields.Description), ("$id", id)))
        {
            update.ExecuteNonQuery();
        }
        return Results.Json(Find(conn, id)!);
    }

    /// <summary>
    /// DELETE /events/{id} -> 204 | 403 not the owner | 404.
    /// An event with sold tickets stays: the tickets must keep their event.
    /// </summary>
    public static IResult Delete(HttpContext context, long id)
    {
        using var conn = Db.Open();
        var existing = Find(conn, id);
        if (existing is null) return Errors.NotFound("Event not found");
        if (existing.OwnerId != Auth.CurrentUserId(context))
            return Errors.Forbidden("Only the organizer can delete the event");

        using (var sold = conn.Cmd("SELECT COUNT(*) FROM tickets WHERE event_id = $id", ("$id", id)))
        {
            if ((long)sold.ExecuteScalar()! > 0)
                return Errors.Validation("The event has tickets and cannot be deleted");
        }

        using var delete = conn.Cmd("DELETE FROM events WHERE id = $id", ("$id", id));
        delete.ExecuteNonQuery();
        return Results.NoContent();
    }

    private record Fields(
        string Title, string Category, string Venue, string StartsAt,
        double Price, string ImageUrl, string Description);

    /// <summary>Checks the input and normalizes it; the date is stored in UTC ISO-8601.</summary>
    private static (Fields?, IResult?) Validate(EventInput input)
    {
        var title = Errors.Trimmed(input.Title);
        if (title is null) return (null, Errors.Validation("title is required"));

        var category = Errors.Trimmed(input.Category);
        if (category is null || !Categories.Contains(category))
            return (null, Errors.Validation($"category must be one of: {string.Join(", ", Categories)}"));

        var venue = Errors.Trimmed(input.Venue);
        if (venue is null) return (null, Errors.Validation("venue is required"));

        if (!DateTimeOffset.TryParse(input.StartsAt, CultureInfo.InvariantCulture,
                DateTimeStyles.AssumeUniversal, out var startsAt))
            return (null, Errors.Validation("startsAt must be an ISO-8601 date and time"));

        var price = input.Price ?? 0;
        if (price < 0) return (null, Errors.Validation("price must not be negative"));

        return (new Fields(title, category, venue, Db.Iso(startsAt), price,
            input.ImageUrl?.Trim() ?? "", input.Description?.Trim() ?? ""), null);
    }
}
