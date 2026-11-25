import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/models/page_result.dart';
import '../../my_tickets/data/demo_tickets.dart';
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
  }) : _events = [...(events ?? demoEvents)]..sort(_byStart);

  final Duration latency;
  final List<Event> _events;
  int _lastId = 0;
  int _lastPoster = 0;

  static int _byStart(Event a, Event b) => a.dateTime.compareTo(b.dateTime);

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

  /// The mock has one user, the demo account, so it organizes every new
  /// event.
  @override
  Future<Event> createEvent(EventDraft draft) async {
    await _wait();
    String id;
    do {
      id = 'n${++_lastId}';
    } while (_events.any((event) => event.id == id));

    final event = Event(
      id: id,
      ownerId: demoUserId,
      title: draft.title,
      category: draft.category,
      venue: draft.venue,
      dateTime: draft.dateTime,
      price: draft.price,
      imageUrl: draft.imageUrl,
      description: draft.description,
    );
    _events
      ..add(event)
      ..sort(_byStart);
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _wait();
    final event = _events.where((event) => event.id == id).firstOrNull;
    if (event == null) throw const EventException(AppTexts.eventNotFound);
    if (event.ownerId != demoUserId) {
      throw const EventException(AppTexts.notOrganizer);
    }
    _events.remove(event);
  }

  /// Nothing is stored: the poster becomes a placeholder picture.
  @override
  Future<String> uploadPoster({
    required List<int> bytes,
    required String filename,
  }) async {
    await _wait();
    return 'https://picsum.photos/seed/eventhub-upload-${++_lastPoster}/600/800';
  }

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }
}
