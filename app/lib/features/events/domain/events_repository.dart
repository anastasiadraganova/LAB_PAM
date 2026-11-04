import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/models/page_result.dart';

/// Source of the city listing.
///
/// Screens and state never know where the events come from: the backend
/// ([ApiEventsRepository]) or memory ([MockEventsRepository]).
abstract interface class EventsRepository {
  /// One page of the listing, sorted by start time. [query] narrows it down
  /// by title, [category] to one category.
  Future<PageResult<Event>> fetchEvents({
    int page = 1,
    int limit = 20,
    String query = '',
    EventCategory? category,
  });

  /// One event, or `null` when there is no event with this [id].
  Future<Event?> fetchEventById(String id);
}
