import '../../../shared/models/event.dart';
import '../domain/events_repository.dart';
import 'demo_events.dart';

/// [EventsRepository] over the hand written demo listing.
///
/// Every call waits for [latency] first, the way a network request would, so
/// that the loading state of the screens can actually be seen.
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
  Future<List<Event>> fetchEvents() async {
    await _wait();
    return _events;
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
