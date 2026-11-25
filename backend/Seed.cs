// Demo data for a fresh database, so the app has a listing to show on its
// first start. Runs only while the events table is empty; set SEED=false to
// start with an empty database instead.
//
// The same listing the Flutter app used as mock data: every category, one
// event in the past, two free ones, a long title, two events today.

namespace PamBackend;

public static class Seed
{
    public const string DemoEmail = "marina@eventhub.md";
    public const string DemoPassword = "eventhub";

    private record DemoEvent(
        string Title, string Category, string Venue, int DayOffset, int Hour, int Minute,
        double Price, string Image, string Description);

    private static readonly DemoEvent[] DemoEvents =
    [
        new("Ночь гаражного рока", "концерт", "Клуб Fabrika", -3, 21, 0, 250, "garage",
            "Четыре местные группы, одна сцена и никакого расписания между сетами. Вход со двора, внутри шумно и тесно, так и задумано."),
        new("Стендап-вечер в подвале", "стендап", "Tap Lab", 0, 20, 0, 150, "standup",
            "Восемь комиков по семь минут каждый, половина материала обкатывается впервые. Столики занимают заранее, опоздавшие стоят у бара."),
        new("Танцы до рассвета: только винил", "вечеринка", "Летняя сцена", 0, 23, 0, 200, "vinyl",
            "Три диджея, две вертушки и ни одного трека с флешки. Фанк, диско и эстрада семидесятых до первого троллейбуса."),
        new("Выставка городской фотографии", "выставка", "Галерея на Пушкина", 1, 12, 0, 0, "photo",
            "Сорок снимков одного двора, сделанных с одной точки за двадцать лет. Вход свободный, экскурсия по выставке в шесть вечера."),
        new("Фестиваль независимой музыки и уличного театра на набережной", "концерт", "Набережная", 1, 17, 30, 300, "festival",
            "Две сцены вдоль воды, между ними ходят на ходулях. Программа идёт до полуночи, последний блок акустический."),
        new("Хакатон городских сервисов", "хакатон", "Тех-парк", 2, 9, 0, 120, "hack",
            "Сорок восемь часов на прототип, который решает одну конкретную городскую проблему. Команды до пяти человек, кофе и розетки на месте."),
        new("Открытый микрофон", "стендап", "Арт-подвал", 3, 19, 30, 90, "openmic",
            "Пять минут на человека, список собирают за полчаса до начала. Выступить может любой, освистать тоже любой."),
        new("Оркестр играет киномузыку", "концерт", "Дом печати", 4, 19, 0, 450, "symphony",
            "Партитуры из фильмов, которые все слышали и почти никто не слушал живьём. Второе отделение с хором."),
        new("Вечеринка кассетного бума", "вечеринка", "Клуб Fabrika", 5, 22, 0, 180, "tape",
            "Приносите свою кассету, её поставят. Дресс-код не объявлен, но спортивные костюмы приветствуются."),
        new("Ризография: открытая мастерская", "выставка", "Малая сцена", 6, 14, 0, 0, "riso",
            "Печатный станок работает весь день, можно принести свой макет и уйти с оттиском. Бумага и краска за счёт мастерской."),
        new("Хакатон по картам города", "хакатон", "Тех-парк", 8, 10, 0, 150, "maps",
            "Открытые данные транспорта и один выходной на то, чтобы сделать из них что-то полезное. Итоги показывают в воскресенье."),
        new("Большой концерт на площади", "концерт", "Центральная площадь", 10, 18, 0, 350, "square",
            "Хедлайнер выходит в девять, разогрев начинается сразу после шести. Площадь перекрывают с полудня."),
        new("Стендап: сольный час", "стендап", "Дом печати", 12, 20, 0, 400, "solo",
            "Час материала, собранного за два года выступлений на открытых микрофонах. Без разогрева и без антракта."),
    ];

    // (event index, qty, stored status). The ticket to the past concert is
    // stored as active and reads as "used" - the status rule does the rest.
    private static readonly (int Event, int Qty, string Status)[] DemoTickets =
    [
        (0, 2, "active"),
        (8, 1, "cancelled"),
        (7, 3, "active"),
        (1, 1, "active"),
    ];

    public static void Run()
    {
        if (Environment.GetEnvironmentVariable("SEED") == "false") return;

        using var conn = Db.Open();
        using (var count = conn.Cmd("SELECT COUNT(*) FROM events"))
        {
            if ((long)count.ExecuteScalar()! > 0) return;
        }

        var userId = DemoUserId(conn);
        var today = new DateTimeOffset(DateTime.Today);
        var eventIds = new List<long>();

        foreach (var e in DemoEvents)
        {
            var startsAt = today.AddDays(e.DayOffset).AddHours(e.Hour).AddMinutes(e.Minute);
            using var insert = conn.Cmd(
                "INSERT INTO events (user_id, title, category, venue, starts_at, price, " +
                "image_url, description, created_at) VALUES ($userId, $title, $category, " +
                "$venue, $startsAt, $price, $imageUrl, $description, $createdAt)",
                ("$userId", userId), ("$title", e.Title), ("$category", e.Category),
                ("$venue", e.Venue), ("$startsAt", Db.Iso(startsAt)), ("$price", e.Price),
                ("$imageUrl", $"https://picsum.photos/seed/eventhub-{e.Image}/600/800"),
                ("$description", e.Description), ("$createdAt", Db.NowIso()));
            insert.ExecuteNonQuery();
            eventIds.Add(conn.LastInsertRowId());
        }

        foreach (var (index, qty, status) in DemoTickets)
        {
            using var insert = conn.Cmd(
                "INSERT INTO tickets (user_id, event_id, qty, total_price, status, created_at) " +
                "VALUES ($userId, $eventId, $qty, $total, $status, $createdAt)",
                ("$userId", userId), ("$eventId", eventIds[index]), ("$qty", qty),
                ("$total", DemoEvents[index].Price * qty), ("$status", status),
                ("$createdAt", Db.NowIso()));
            insert.ExecuteNonQuery();
        }
    }

    /// <summary>The demo account, created if it does not exist yet.</summary>
    private static long DemoUserId(Microsoft.Data.Sqlite.SqliteConnection conn)
    {
        using (var existing = conn.Cmd("SELECT id FROM users WHERE email = $email",
                   ("$email", DemoEmail)))
        {
            if (existing.ExecuteScalar() is long id) return id;
        }

        using var insert = conn.Cmd(
            "INSERT INTO users (email, password_hash, name, created_at) " +
            "VALUES ($email, $hash, $name, $createdAt)",
            ("$email", DemoEmail), ("$hash", Auth.HashPassword(DemoPassword)),
            ("$name", "Марина Драганова"), ("$createdAt", Db.NowIso()));
        insert.ExecuteNonQuery();
        return conn.LastInsertRowId();
    }
}
