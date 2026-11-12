import 'dart:convert';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_cache.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/models/page_result.dart';
import '../domain/events_repository.dart';
import 'api_events_repository.dart';

/// Offline cache in front of [EventsRepository].
///
/// Every page of the unfiltered listing that comes from the backend is kept
/// on the device. When the backend cannot be reached, the listing, its
/// filters and the event cards are served from that copy, marked
/// [PageResult.fromCache] so the screen can say so. Changes (publishing,
/// deleting) are never faked offline: they need the backend.
class CachedEventsRepository implements EventsRepository {
  CachedEventsRepository(this._remote, this._cache);

  static const String _key = 'cache.events';

  final EventsRepository _remote;
  final LocalCache _cache;

  @override
  Future<PageResult<Event>> fetchEvents({
    int page = 1,
    int limit = 20,
    String query = '',
    EventCategory? category,
  }) async {
    try {
      final result = await _remote.fetchEvents(
        page: page,
        limit: limit,
        query: query,
        category: category,
      );
      if (query.trim().isEmpty && category == null) {
        await _remember(result, startOver: page == 1);
      }
      return result;
    } on ApiException catch (error) {
      if (!error.isNetwork) rethrow;
      final cached = await _cached();
      if (cached == null) rethrow;
      return _page(cached, page, limit, query, category);
    }
  }

  @override
  Future<Event?> fetchEventById(String id) async {
    try {
      return await _remote.fetchEventById(id);
    } on ApiException catch (error) {
      if (!error.isNetwork) rethrow;
      final cached = await _cached();
      final event = cached?.where((event) => event.id == id).firstOrNull;
      if (event == null) rethrow;
      return event;
    }
  }

  @override
  Future<Event> createEvent(EventDraft draft) => _remote.createEvent(draft);

  @override
  Future<void> deleteEvent(String id) => _remote.deleteEvent(id);

  @override
  Future<String> uploadPoster({
    required List<int> bytes,
    required String filename,
  }) => _remote.uploadPoster(bytes: bytes, filename: filename);

  /// Page 1 starts the copy over; later pages are added to it.
  Future<void> _remember(
    PageResult<Event> result, {
    required bool startOver,
  }) async {
    final kept = startOver ? <Event>[] : (await _cached() ?? <Event>[]);
    final ids = {for (final event in kept) event.id};
    final events = [
      ...kept,
      for (final event in result.items)
        if (!ids.contains(event.id)) event,
    ];
    await _cache.write(
      _key,
      jsonEncode([
        for (final event in events) ApiEventsRepository.eventToJson(event),
      ]),
    );
  }

  Future<List<Event>?> _cached() async {
    final raw = await _cache.read(_key);
    if (raw == null) return null;
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          ApiEventsRepository.eventFromJson(item as Map<String, dynamic>),
      ];
    } on Object {
      // A copy written by an older version of the app: ignore it.
      return null;
    }
  }

  /// Filters and pages the copy the way the backend would.
  PageResult<Event> _page(
    List<Event> events,
    int page,
    int limit,
    String query,
    EventCategory? category,
  ) {
    final search = query.trim().toLowerCase();
    final matching = events
        .where(
          (event) =>
              (category == null || event.category == category) &&
              (search.isEmpty || event.title.toLowerCase().contains(search)),
        )
        .toList();
    return PageResult(
      items: matching.skip((page - 1) * limit).take(limit).toList(),
      page: page,
      limit: limit,
      total: matching.length,
      fromCache: true,
    );
  }
}
