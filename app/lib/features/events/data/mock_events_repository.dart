import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/models/page_result.dart';
import '../domain/events_repository.dart';
import 'demo_events.dart';

/// [EventsRepository] over the hand written demo listing.
///
/// It filters and pages in memory exactly as the backend does, and every
/// call waits for [latency] first, the way a network request would.
class MockEventsRepository implements EventsRepository {
  MockEventsRepository({
    this.latency = const Duration(milliseconds: 400),
    List<Event>? events,
  }) : _events = List<Event>.unmodifiable(
         [...(events ?? demoEvents)]
           ..sort((a, b) => a.dateTime.compareTo(b.dateTime)),
       );

  final Duration latency;
  final List<Event> _events;

  @override
  Future<PageResult<Event>> fetchEvents({
    int page = 1,
    int limit = 20,
    String query = '',
    EventCategory? category,
  }) async {
    await _wait();

    final search = query.trim().toLowerCase();
    final matching = _events
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
    );
  }

  @override
  Future<Event?> fetchEventById(String id) async {
    await _wait();
    for (final event in _events) {
      if (event.id == id) return event;
    }
    return null;
  }

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }
}
