# EventHub

Афиша городских событий: концерты, стендап, выставки, хакатоны и вечеринки в
одном списке, с покупкой билетов прямо в приложении.

**Стек:** Flutter + Riverpod + dio (клиент), .NET 9 Minimal API + SQLite на основе
шаблона курса (backend), JWT.

## Документы

| Файл | О чём |
|------|-------|
| [SPEC.md](./SPEC.md) | Экраны, модель данных, endpoint-ы, правила валидации |
| [DESIGN.md](./DESIGN.md) | Цвета, типографика, компоненты, тексты интерфейса |
| [PLAN.md](./PLAN.md) | Порядок разработки по этапам L1–L6 |

## Запуск

Сначала backend (нужен .NET SDK 9). База `app.db` и папка `uploads/` создаются
сами; в пустую базу записываются демо-аккаунт, 13 событий и 4 билета.

```bash
cd backend
dotnet run
```

Сервер слушает `http://localhost:8080` (порт меняется переменной `PORT`).

Потом приложение:

```bash
cd app
flutter pub get
flutter run
```

Адрес API по умолчанию — `localhost:8080`, из эмулятора Android — `10.0.2.2:8080`.
Для телефона в той же сети:
`flutter run --dart-define=API_URL=http://<IP компьютера>:8080`.
Без сервера: `flutter run --dart-define=USE_MOCKS=true`.

Демо-аккаунт: `marina@eventhub.md` / `eventhub`.

## Структура

```
app/      Flutter-приложение
backend/  .NET Minimal API на основе шаблона курса
```

## Backend

Шаблон курса (`Auth.cs`, `Errors.cs`, `Files.cs`, `Notes.cs`, `Db.cs`) дал
JWT-аутентификацию, CRUD с пагинацией, загрузку файлов и единый формат ошибок
`{"error": {"code", "message"}}`. Сущности EventHub добавлены по его рецепту:
таблицы в `Db.cs`, файлы `Events.cs`, `Tickets.cs`, маршруты в `Program.cs`,
демо-данные в `Seed.cs`.

| Метод и путь | Что делает |
|--------------|-----------|
| `POST /auth/register`, `POST /auth/login`, `GET /me` | аккаунт и JWT (из шаблона) |
| `GET /events?page&limit&search&category` | афиша по страницам, поиск, фильтр |
| `GET /events/{id}` | одно событие |
| `POST /events`, `PUT /events/{id}`, `DELETE /events/{id}` | создание, изменение и удаление; менять может только организатор, событие с билетами не удаляется |
| `GET /tickets?page&limit` | билеты пользователя, новые сверху |
| `POST /tickets` | покупка: от 1 до 10 билетов, не на прошедшее событие |
| `POST /tickets/{id}/cancel` | отмена активного билета |
| `POST /files`, `GET /files/{id}` | загрузка и выдача постера (из шаблона) |

Все маршруты, кроме входа и `GET /files/{id}`, требуют `Authorization: Bearer`.

## Архитектура клиента

Каждая фича в `app/lib/features/<фича>/` разделена на три слоя:

| Слой | Что лежит | Пример |
|------|-----------|--------|
| `domain/` | контракт репозитория и его ошибки | `EventsRepository`, `TicketException` |
| `data/` | реализация репозитория и mock-данные | `MockEventsRepository`, `demo_events.dart` |
| `presentation/` | состояние (Riverpod) и экраны | `EventFiltersController`, `EventsScreen` |

**Repository.** Экраны и состояние знают только интерфейсы из `domain/`.
Какая реализация стоит за интерфейсом, решается в одном месте —
`core/di/providers.dart`: `Api*Repository` ходят в backend через `ApiClient`
(`core/network/`: dio, JWT из защищённого хранилища, ошибки шаблона в
`ApiException`), `Mock*Repository` работают в памяти — для тестов и запуска без
сервера.

**State management — Riverpod 3.**

| Провайдер | Тип | Что хранит |
|-----------|-----|------------|
| `authControllerProvider` | `AsyncNotifier<User?>` | сессию: вход, регистрация, выход, ошибка входа |
| `eventsListProvider` | `AsyncNotifier` | афишу по страницам под текущими фильтрами, подгрузку следующей |
| `eventByIdProvider` | `FutureProvider.family` | одно событие по id |
| `eventFiltersProvider` | `Notifier` | категорию и строку поиска (их применяет backend) |
| `eventActionsProvider` | `Provider` | публикацию события с постером и удаление |
| `ticketsControllerProvider` | `AsyncNotifier<List<Ticket>>` | билеты пользователя, покупку и отмену |
| `routerProvider` | `Provider<GoRouter>` | маршруты; редиректы следуют за сессией |

Тесты: `cd app && flutter test` — сервер для них не нужен.
