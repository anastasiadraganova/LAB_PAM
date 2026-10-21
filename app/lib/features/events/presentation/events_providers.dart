import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';

/// The whole listing as loaded from the repository. Kept for the session, so
/// returning to the listing does not load it again; pull to refresh reloads.
final eventsProvider = FutureProvider<List<Event>>(
  (ref) => ref.watch(eventsRepositoryProvider).fetchEvents(),
);

/// One event by its identifier, `null` when there is none.
final eventByIdProvider = FutureProvider.family<Event?, String>(
  (ref, id) => ref.watch(eventsRepositoryProvider).fetchEventById(id),
);

/// What the listing is narrowed down to: a category and a search query.
@immutable
class EventFilters {
  const EventFilters({this.category, this.query = ''});

  /// `null` means "Все".
  final EventCategory? category;
  final String query;

  bool get isEmpty => category == null && query.trim().isEmpty;

  bool matches(Event event) {
    final query = this.query.trim().toLowerCase();
    final matchesCategory = category == null || event.category == category;
    final matchesQuery =
        query.isEmpty || event.title.toLowerCase().contains(query);
    return matchesCategory && matchesQuery;
  }

  @override
  bool operator ==(Object other) =>
      other is EventFilters &&
      other.category == category &&
      other.query == query;

  @override
  int get hashCode => Object.hash(category, query);
}

final eventFiltersProvider =
    NotifierProvider<EventFiltersController, EventFilters>(
      EventFiltersController.new,
    );

class EventFiltersController extends Notifier<EventFilters> {
  @override
  EventFilters build() => const EventFilters();

  void setCategory(EventCategory? category) =>
      state = EventFilters(category: category, query: state.query);

  void setQuery(String query) =>
      state = EventFilters(category: state.category, query: query);

  void reset() => state = const EventFilters();
}

/// The listing as the screen shows it: loaded events passed through the
/// filters. Loading and errors of the listing come through unchanged.
final visibleEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final filters = ref.watch(eventFiltersProvider);
  return ref
      .watch(eventsProvider)
      .whenData(
        (events) => events.where(filters.matches).toList(growable: false),
      );
});
