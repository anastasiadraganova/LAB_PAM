import 'package:flutter/foundation.dart';

import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/models/page_result.dart';

/// An operation on events refused by the rules; [message] is ready to show.
class EventException implements Exception {
  const EventException(this.message);

  final String message;

  @override
  String toString() => 'EventException: $message';
}

/// A new event as the organizer fills it in, before it has an identifier.
@immutable
class EventDraft {
  const EventDraft({
    required this.title,
    required this.category,
    required this.venue,
    required this.dateTime,
    required this.price,
    this.description = '',
    this.imageUrl = '',
  });

  final String title;
  final EventCategory category;
  final String venue;
  final DateTime dateTime;
  final double price;
  final String description;

  /// The poster, as returned by [EventsRepository.uploadPoster].
  final String imageUrl;

  EventDraft withImage(String imageUrl) => EventDraft(
    title: title,
    category: category,
    venue: venue,
    dateTime: dateTime,
    price: price,
    description: description,
    imageUrl: imageUrl,
  );
}

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

  /// Publishes an event on behalf of the signed in user, its organizer.
  ///
  /// Throws [EventException] when the event is refused.
  Future<Event> createEvent(EventDraft draft);

  /// Deletes an event of the signed in user.
  ///
  /// Throws [EventException] when the event has tickets or belongs to
  /// someone else.
  Future<void> deleteEvent(String id);

  /// Uploads a poster image and returns the address to put in
  /// [EventDraft.imageUrl].
  Future<String> uploadPoster({
    required List<int> bytes,
    required String filename,
  });
}
