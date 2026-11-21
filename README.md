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

## Без сети

Последняя загруженная афиша, билеты пользователя и сам аккаунт сохраняются на
устройстве (`shared_preferences`, постеры — в дисковом кэше
`cached_network_image`). Если сервер недоступен, приложение открывается под
тем же аккаунтом, показывает сохранённую копию с пометкой «Нет соединения.
Показана последняя загруженная афиша.», фильтрует её на месте. Покупка, отмена
и публикация требуют сети. Выход из аккаунта стирает его копию и билеты.

## Release-сборка

Android (APK, Dart-код обфусцирован, символы для разбора сбоев — в
`build/symbols`, их не публикуют):

```bash
cd app
flutter build apk --release --obfuscate --split-debug-info=build/symbols \
  --dart-define=API_URL=http://<адрес сервера>:8080
```

Готовый файл: `app/build/app/outputs/flutter-apk/app-release.apk`. Подпись
берётся из `app/android/key.properties` (в git не попадает):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=C:/путь/к/upload-keystore.jks
```

Ключ создаётся один раз:
`keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`.
Без `key.properties` release-сборка подписывается отладочным ключом — для
проверки этого хватает, для публикации нет.

Backend:

```bash
cd backend
dotnet publish -c Release -o publish
cd publish
set JWT_SECRET=<длинная случайная строка>
dotnet PamBackend.dll
```

В release секрет JWT обязательно задаётся переменной `JWT_SECRET`: значение по
умолчанию из шаблона годится только для лабораторной.

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
`ApiException`), `Cached*Repository` оборачивают их и отдают сохранённую копию,
когда сети нет, `Mock*Repository` работают в памяти — для тестов и запуска без
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
