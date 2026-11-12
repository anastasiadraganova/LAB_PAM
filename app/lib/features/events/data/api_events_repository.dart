import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/models/page_result.dart';
import '../domain/events_repository.dart';

/// [EventsRepository] over the backend: `GET /events` with the template's
/// pagination (`page`, `limit`) plus `search` and `category`, and
/// `GET /events/{id}`.
class ApiEventsRepository implements EventsRepository {
  ApiEventsRepository(this._api);

  final ApiClient _api;

  @override
  Future<PageResult<Event>> fetchEvents({
    int page = 1,
    int limit = 20,
    String query = '',
    EventCategory? category,
  }) async {
    final json = await _api.get(
      '/events',
      query: {
        'page': page,
        'limit': limit,
        if (query.trim().isNotEmpty) 'search': query.trim(),
        if (category != null) 'category': category.value,
      },
    );
    return PageResult.fromJson(json, eventFromJson);
  }

  @override
  Future<Event?> fetchEventById(String id) async {
    try {
      return eventFromJson(await _api.get('/events/$id'));
    } on ApiException catch (error) {
      if (error.code == ApiException.notFound) return null;
      rethrow;
    }
  }

  @override
  Future<Event> createEvent(EventDraft draft) => _guard(
    () async => eventFromJson(
      await _api.post('/events', {
        'title': draft.title,
        'category': draft.category.value,
        'venue': draft.venue,
        'startsAt': draft.dateTime.toUtc().toIso8601String(),
        'price': draft.price,
        'imageUrl': draft.imageUrl,
        'description': draft.description,
      }),
    ),
  );

  @override
  Future<void> deleteEvent(String id) =>
      _guard(() => _api.delete('/events/$id'));

  /// `POST /files` from the template; the answer's `url` is a path on the
  /// backend (`/files/7`), stored as is and resolved when events are read.
  @override
  Future<String> uploadPoster({
    required List<int> bytes,
    required String filename,
  }) => _guard(() async {
    final json = await _api.upload('/files', bytes: bytes, filename: filename);
    return json['url'] as String;
  });

  /// The backend's refusals, in the words the screens use.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on ApiException catch (error) {
      throw EventException(switch (error) {
        ApiException(isNetwork: true) => AppTexts.networkError,
        ApiException(code: ApiException.notFound) => AppTexts.eventNotFound,
        ApiException(code: ApiException.forbidden) => AppTexts.notOrganizer,
        ApiException(code: ApiException.validation, :final message)
            when message.contains('tickets') =>
          AppTexts.eventHasTickets,
        ApiException(code: ApiException.validation, :final message)
            when message.contains('too large') =>
          AppTexts.posterTooLarge,
        _ => AppTexts.somethingWrong,
      });
    }
  }

  /// The same shape the backend sends, for the offline cache.
  static Map<String, Object?> eventToJson(Event event) => {
    'id': event.id,
    'ownerId': event.ownerId,
    'title': event.title,
    'category': event.category.value,
    'venue': event.venue,
    'startsAt': event.dateTime.toUtc().toIso8601String(),
    'price': event.price,
    'imageUrl': event.imageUrl,
    'description': event.description,
  };

  /// The backend keeps dates in UTC; the app shows them in local time.
  static Event eventFromJson(Map<String, dynamic> json) => Event(
    id: '${json['id']}',
    ownerId: '${json['ownerId']}',
    title: json['title'] as String,
    category:
        EventCategory.byValue(json['category'] as String) ??
        EventCategory.concert,
    venue: json['venue'] as String,
    dateTime: DateTime.parse(json['startsAt'] as String).toLocal(),
    price: (json['price'] as num).toDouble(),
    imageUrl: ApiConfig.resolve(json['imageUrl'] as String? ?? ''),
    description: json['description'] as String? ?? '',
  );
}
