# EventHub

Афиша городских событий: концерты, стендап, выставки, хакатоны и вечеринки в
одном списке, с покупкой билетов прямо в приложении.

**Стек:** Flutter (клиент), .NET + Entity Framework Core (backend), JWT.

## Документы

| Файл | О чём |
|------|-------|
| [SPEC.md](./SPEC.md) | Экраны, модель данных, endpoint-ы, правила валидации |
| [DESIGN.md](./DESIGN.md) | Цвета, типографика, компоненты, тексты интерфейса |
| [PLAN.md](./PLAN.md) | Порядок разработки по этапам L1–L6 |

## Запуск

Приложение:

```bash
cd app
flutter pub get
flutter run
```

Backend:

```bash
cd backend
dotnet restore
dotnet ef database update
dotnet run
```

Базовый URL API задаётся в конфигурации приложения; Swagger UI доступен на
корне backend-а в режиме разработки.

## Структура

```
app/      Flutter-приложение
backend/  ASP.NET Core API
```

## Архитектура клиента

Каждая фича в `app/lib/features/<фича>/` разделена на три слоя:

| Слой | Что лежит | Пример |
|------|-----------|--------|
| `domain/` | контракт репозитория и его ошибки | `EventsRepository`, `TicketException` |
| `data/` | реализация репозитория и mock-данные | `MockEventsRepository`, `demo_events.dart` |
| `presentation/` | состояние (Riverpod) и экраны | `EventFiltersController`, `EventsScreen` |

**Repository.** Экраны и состояние знают только интерфейсы из `domain/`.
Какая реализация стоит за интерфейсом, решается в одном месте —
`core/di/providers.dart`. Сейчас это mock-репозитории в памяти с имитацией
задержки сети; на этапе с backend-ом там же появятся HTTP-реализации, остальной
код не меняется.

**State management — Riverpod 3.**

| Провайдер | Тип | Что хранит |
|-----------|-----|------------|
| `authControllerProvider` | `AsyncNotifier<User?>` | сессию: вход, регистрация, выход, ошибка входа |
| `eventsProvider` | `FutureProvider` | афишу из репозитория |
| `eventByIdProvider` | `FutureProvider.family` | одно событие по id |
| `eventFiltersProvider` | `Notifier` | категорию и строку поиска |
| `visibleEventsProvider` | `Provider` | афишу после фильтров |
| `ticketsControllerProvider` | `AsyncNotifier<List<Ticket>>` | билеты пользователя, покупку и отмену |
| `routerProvider` | `Provider<GoRouter>` | маршруты; редиректы следуют за сессией |

Демо-аккаунт mock-репозитория: `marina@eventhub.md` / `eventhub`.

Тесты: `cd app && flutter test`.
