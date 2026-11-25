import '../../../shared/models/event.dart';

/// Source of the city listing.
///
/// Screens and state never know where the events come from: today it is the
/// in-memory [MockEventsRepository], at the next stage a client of the backend
/// API takes its place behind the same contract.
abstract interface class EventsRepository {
  /// The whole listing, sorted by start time.
  Future<List<Event>> fetchEvents();

  /// One event, or `null` when there is no event with this [id].
  Future<Event?> fetchEventById(String id);
}
