import 'event_category.dart';

/// A single item of the city listing.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.venue,
    required this.dateTime,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  final String id;
  final String title;
  final EventCategory category;
  final String venue;

  /// Start of the event, in local time.
  final DateTime dateTime;

  /// Price of a single ticket. Zero means the event is free.
  final double price;

  /// Poster.
  final String imageUrl;

  final String description;

  bool get isFree => price == 0;

  bool isPast({DateTime? now}) => dateTime.isBefore(now ?? DateTime.now());

  /// The day the event belongs to, with the time stripped, for grouping the
  /// listing under day separators.
  DateTime get day => DateTime(dateTime.year, dateTime.month, dateTime.day);
}
