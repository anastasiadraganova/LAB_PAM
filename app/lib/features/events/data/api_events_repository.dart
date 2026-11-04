import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
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
