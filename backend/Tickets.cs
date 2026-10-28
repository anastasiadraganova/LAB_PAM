// Tickets: purchases of the signed in user. Built from Notes.cs.
//
// A ticket is never deleted or edited: it is bought, and later it may be
// cancelled, which only changes its status. Once the event has started an
// active ticket reads as "used" - that status is derived, not stored.

using Microsoft.Data.Sqlite;

namespace PamBackend;

public record Ticket(
    long Id, long EventId, long UserId, int Qty, double TotalPrice, string Status, string CreatedAt);

public record TicketInput(long? EventId, int? Qty);

public static class Tickets
{
    public const int MinQty = 1;
    public const int MaxQty = 10;

    // The status as the client sees it: an active ticket to a started event is used.
    private const string Select =
        "SELECT t.id, t.event_id, t.user_id, t.qty, t.total_price, " +
        "CASE WHEN t.status = 'active' AND e.starts_at <= $now THEN 'used' ELSE t.status END, " +
        "t.created_at FROM tickets t JOIN events e ON e.id = t.event_id";

    private static Ticket ReadTicket(SqliteDataReader r) => new(
        r.GetInt64(0), r.GetInt64(1), r.GetInt64(2), r.GetInt32(3), r.GetDouble(4),
        r.GetString(5), r.GetString(6));

    /// <summary>Someone else's ticket is indistinguishable from a missing one (404).</summary>
    private static Ticket? Find(SqliteConnection conn, long userId, long id)
    {
        using var cmd = conn.Cmd($"{Select} WHERE t.id = $id AND t.user_id = $userId",
            ("$id", id), ("$userId", userId), ("$now", Db.NowIso()));
        using var reader = cmd.ExecuteReader();
        return reader.Read() ? ReadTicket(reader) : null;
    }

    /// <summary>GET /tickets?page=1&amp;limit=20 -> {items, page, limit, total}, newest first.</summary>
    public static IResult List(HttpContext context, int page = 1, int limit = 20)
    {
        page = Math.Max(page, 1);
        limit = Math.Clamp(limit, 1, 100);
        var userId = Auth.CurrentUserId(context);

        using var conn = Db.Open();
        long total;
        using (var count = conn.Cmd("SELECT COUNT(*) FROM tickets WHERE user_id = $userId",
                   ("$userId", userId)))
        {
            total = (long)count.ExecuteScalar()!;
        }

        var items = new List<Ticket>();
        using var cmd = conn.Cmd(
            $"{Select} WHERE t.user_id = $userId ORDER BY t.id DESC LIMIT $limit OFFSET $offset",
            ("$userId", userId), ("$now", Db.NowIso()),
            ("$limit", limit), ("$offset", (page - 1) * limit));
        using var reader = cmd.ExecuteReader();
        while (reader.Read()) items.Add(ReadTicket(reader));

        return Results.Json(new { items, page, limit, total });
    }

    /// <summary>GET /tickets/{id} -> 200 ticket | 404</summary>
    public static IResult GetOne(HttpContext context, long id)
    {
        using var conn = Db.Open();
        var ticket = Find(conn, Auth.CurrentUserId(context), id);
        return ticket is null ? Errors.NotFound("Ticket not found") : Results.Json(ticket);
    }

    /// <summary>
    /// POST /tickets {eventId, qty} -> 201 ticket.
    /// 1 to 10 tickets per order; no sales once the event has started. The
    /// total is fixed now, at the current price of the event.
    /// </summary>
    public static IResult Create(HttpContext context, TicketInput input)
    {
        if (input.Qty is not (>= MinQty and <= MaxQty))
            return Errors.Validation($"qty must be from {MinQty} to {MaxQty}");
        if (input.EventId is null) return Errors.Validation("eventId is required");

        using var conn = Db.Open();
        var ev = Events.Find(conn, input.EventId.Value);
        if (ev is null) return Errors.NotFound("Event not found");
        if (string.CompareOrdinal(ev.StartsAt, Db.NowIso()) <= 0)
            return Errors.Validation("The event has already started");

        var userId = Auth.CurrentUserId(context);
        using (var insert = conn.Cmd(
                   "INSERT INTO tickets (user_id, event_id, qty, total_price, status, created_at) " +
                   "VALUES ($userId, $eventId, $qty, $total, 'active', $createdAt)",
                   ("$userId", userId), ("$eventId", ev.Id), ("$qty", input.Qty.Value),
                   ("$total", ev.Price * input.Qty.Value), ("$createdAt", Db.NowIso())))
        {
            insert.ExecuteNonQuery();
        }
        var ticket = Find(conn, userId, conn.LastInsertRowId())!;
        return Results.Created($"/tickets/{ticket.Id}", ticket);
    }

    /// <summary>POST /tickets/{id}/cancel -> 200 ticket | 400 not active | 404</summary>
    public static IResult Cancel(HttpContext context, long id)
    {
        var userId = Auth.CurrentUserId(context);
        using var conn = Db.Open();
        var ticket = Find(conn, userId, id);
        if (ticket is null) return Errors.NotFound("Ticket not found");
        if (ticket.Status != "active")
            return Errors.Validation("Only an active ticket can be cancelled");

        using (var update = conn.Cmd(
                   "UPDATE tickets SET status = 'cancelled' WHERE id = $id", ("$id", id)))
        {
            update.ExecuteNonQuery();
        }
        return Results.Json(Find(conn, userId, id)!);
    }
}
