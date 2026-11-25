import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eventhub/core/network/api_client.dart';
import 'package:eventhub/core/network/token_storage.dart';
import 'package:eventhub/features/auth/data/api_auth_repository.dart';
import 'package:eventhub/features/auth/domain/auth_repository.dart';
import 'package:eventhub/features/events/data/api_events_repository.dart';
import 'package:eventhub/shared/app_texts.dart';
import 'package:eventhub/shared/models/event_category.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers requests from a table instead of the network and remembers what
/// was asked, so the API repositories can be checked in milliseconds.
class _FakeBackend implements HttpClientAdapter {
  _FakeBackend(this.routes);

  /// `"GET /events"` -> (status, JSON body).
  final Map<String, (int, Object)> routes;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) =
        routes['${options.method} ${options.path}'] ??
        (404, _error('NOT_FOUND', 'Route not found'));
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object> _error(String code, String message) => {
  'error': {'code': code, 'message': message},
};

void main() {
  late MemoryTokenStorage tokens;

  ApiClient client(_FakeBackend backend, {void Function()? onUnauthorized}) {
    final dio = Dio()..httpClientAdapter = backend;
    return ApiClient(
      baseUrl: 'http://api.test',
      tokens: tokens,
      onUnauthorized: onUnauthorized,
      dio: dio,
    );
  }

  setUp(() => tokens = MemoryTokenStorage());

  test(
    'sign-in keeps the token; a template error becomes the Russian text',
    () async {
      final backend = _FakeBackend({
        'POST /auth/login': (
          200,
          {
            'token': 'jwt-1',
            'user': {'id': 1, 'email': 'm@e.md', 'name': 'Марина'},
          },
        ),
        'POST /auth/register': (409, _error('EMAIL_TAKEN', 'taken')),
      });
      final auth = ApiAuthRepository(client(backend));

      final user = await auth.signIn(email: 'm@e.md', password: 'secret1');
      expect(user.id, '1');
      expect(await tokens.read(), 'jwt-1');

      await expectLater(
        auth.signUp(name: 'М', email: 'm@e.md', password: 'secret1'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            AppTexts.emailTaken,
          ),
        ),
      );
    },
  );

  test('a page of events is read with its filters and file paths', () async {
    await tokens.write('jwt-1');
    final backend = _FakeBackend({
      'GET /events': (
        200,
        {
          'items': [
            {
              'id': 7,
              'ownerId': 2,
              'title': 'Хакатон',
              'category': 'хакатон',
              'venue': 'Тех-парк',
              'startsAt': '2030-01-01T18:00:00.0000000Z',
              'price': 120,
              'imageUrl': '/files/3',
              'description': '',
            },
          ],
          'page': 2,
          'limit': 1,
          'total': 3,
        },
      ),
    });
    final events = ApiEventsRepository(client(backend));

    final page = await events.fetchEvents(
      page: 2,
      limit: 1,
      query: 'хак',
      category: EventCategory.hackathon,
    );

    final request = backend.requests.single;
    expect(request.headers['Authorization'], 'Bearer jwt-1');
    expect(request.queryParameters, {
      'page': 2,
      'limit': 1,
      'search': 'хак',
      'category': 'хакатон',
    });

    final event = page.items.single;
    expect(event.id, '7');
    expect(event.price, 120.0);
    expect(event.imageUrl, endsWith('/files/3'));
    expect(event.dateTime.isUtc, isFalse);
    expect(page.hasMore, isTrue);
  });

  test('a rejected token is dropped and ends the session', () async {
    await tokens.write('expired');
    var sessionEnded = false;
    final backend = _FakeBackend({
      'GET /events': (401, _error('UNAUTHORIZED', 'Missing or invalid token')),
    });
    final events = ApiEventsRepository(
      client(backend, onUnauthorized: () => sessionEnded = true),
    );

    await expectLater(events.fetchEvents(), throwsA(anything));
    expect(await tokens.read(), isNull);
    expect(sessionEnded, isTrue);
  });
}
