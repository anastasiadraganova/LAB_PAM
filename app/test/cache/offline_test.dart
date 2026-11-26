import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eventhub/core/network/api_client.dart';
import 'package:eventhub/core/network/api_exception.dart';
import 'package:eventhub/core/network/token_storage.dart';
import 'package:eventhub/core/storage/local_cache.dart';
import 'package:eventhub/features/auth/data/api_auth_repository.dart';
import 'package:eventhub/features/events/data/cached_events_repository.dart';
import 'package:eventhub/features/events/data/mock_events_repository.dart';
import 'package:eventhub/features/events/domain/events_repository.dart';
import 'package:eventhub/features/my_tickets/data/cached_tickets_repository.dart';
import 'package:eventhub/features/my_tickets/data/mock_tickets_repository.dart';
import 'package:eventhub/features/my_tickets/domain/tickets_repository.dart';
import 'package:eventhub/shared/models/event.dart';
import 'package:eventhub/shared/models/event_category.dart';
import 'package:eventhub/shared/models/page_result.dart';
import 'package:eventhub/shared/models/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

const _noNetwork = ApiException(code: ApiException.network, message: 'offline');

/// The demo listing that can be switched off like a lost connection.
class _FlakyEvents implements EventsRepository {
  final _inner = MockEventsRepository(latency: Duration.zero);
  bool online = true;

  @override
  Future<PageResult<Event>> fetchEvents({
    int page = 1,
    int limit = 20,
    String query = '',
    EventCategory? category,
  }) {
    if (!online) throw _noNetwork;
    return _inner.fetchEvents(
      page: page,
      limit: limit,
      query: query,
      category: category,
    );
  }

  @override
  Future<Event?> fetchEventById(String id) {
    if (!online) throw _noNetwork;
    return _inner.fetchEventById(id);
  }

  @override
  Future<Event> createEvent(EventDraft draft) async => throw _noNetwork;

  @override
  Future<void> deleteEvent(String id) async => throw _noNetwork;

  @override
  Future<String> uploadPoster({
    required List<int> bytes,
    required String filename,
  }) async => throw _noNetwork;
}

class _FlakyTickets implements TicketsRepository {
  final _inner = MockTicketsRepository(latency: Duration.zero);
  bool online = true;

  @override
  Future<List<Ticket>> fetchTickets(String userId) {
    if (!online) throw _noNetwork;
    return _inner.fetchTickets(userId);
  }

  @override
  Future<Ticket> purchase({
    required String userId,
    required Event event,
    required int qty,
  }) async => throw _noNetwork;

  @override
  Future<Ticket> cancel(String ticketId) async => throw _noNetwork;
}

/// A backend that answers sign-in, then disappears.
class _Backend implements HttpClientAdapter {
  bool online = true;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!online) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'token': 'jwt',
        'user': {'id': 1, 'email': 'm@e.md', 'name': 'Марина'},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MemoryCache cache;

  setUp(() => cache = MemoryCache());

  test(
    'offline, the listing comes from the saved pages, filters included',
    () async {
      final remote = _FlakyEvents();
      final events = CachedEventsRepository(remote, cache);
      final first = await events.fetchEvents(limit: 10);
      await events.fetchEvents(page: 2, limit: 10);
      expect(first.fromCache, isFalse);

      remote.online = false;
      final offline = await events.fetchEvents(limit: 10);
      expect(offline.fromCache, isTrue);
      expect(offline.total, first.total);

      final hackathons = await events.fetchEvents(
        category: EventCategory.hackathon,
      );
      expect(hackathons.items, isNotEmpty);
      expect(
        hackathons.items.every((e) => e.category == EventCategory.hackathon),
        isTrue,
      );
      expect((await events.fetchEventById('e13'))?.title, isNotNull);

      // Nothing to fall back on for a change: that needs the backend.
      await expectLater(
        events.deleteEvent('e13'),
        throwsA(isA<ApiException>()),
      );
    },
  );

  test('offline, "Мои билеты" shows the last loaded tickets', () async {
    final remote = _FlakyTickets();
    final tickets = CachedTicketsRepository(remote, cache);
    final online = await tickets.fetchTickets('u1');

    remote.online = false;
    final offline = await tickets.fetchTickets('u1');
    expect(
      offline.map((t) => (t.id, t.status)),
      online.map((t) => (t.id, t.status)),
    );
    await expectLater(tickets.fetchTickets('u2'), throwsA(isA<ApiException>()));
  });

  test(
    'offline, the app opens signed in; signing out forgets the account',
    () async {
      final backend = _Backend();
      final tokens = MemoryTokenStorage();
      ApiAuthRepository repository() => ApiAuthRepository(
        ApiClient(
          baseUrl: 'http://api.test',
          tokens: tokens,
          dio: Dio()..httpClientAdapter = backend,
        ),
        cache,
      );

      await repository().signIn(email: 'm@e.md', password: 'secret1');
      backend.online = false;

      final restored = repository();
      await restored.restoreSession();
      expect(restored.currentUser?.email, 'm@e.md');

      await restored.signOut();
      final afterSignOut = repository();
      await afterSignOut.restoreSession();
      expect(afterSignOut.currentUser, isNull);
    },
  );
}
