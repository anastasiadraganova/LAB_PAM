import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/models/page_result.dart';
import '../domain/events_repository.dart';

/// One event by its identifier, `null` when there is none.
final eventByIdProvider = FutureProvider.family<Event?, String>(
  (ref, id) => ref.watch(eventsRepositoryProvider).fetchEventById(id),
);

/// What the listing is narrowed down to: a category and a search query. The
/// backend applies both, so a change of filters loads the listing anew.
@immutable
class EventFilters {
  const EventFilters({this.category, this.query = ''});

  /// `null` means "Все".
  final EventCategory? category;
  final String query;

  bool get isEmpty => category == null && query.trim().isEmpty;

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

/// The pages of the listing loaded so far.
@immutable
class EventsListState {
  const EventsListState({
    required this.items,
    required this.page,
    required this.total,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Event> items;

  /// The last page loaded.
  final int page;

  /// Size of the whole listing under the current filters.
  final int total;

  final bool isLoadingMore;
  final bool loadMoreFailed;

  bool get hasMore => items.length < total;

  EventsListState copyWith({bool? isLoadingMore, bool? loadMoreFailed}) =>
      EventsListState(
        items: items,
        page: page,
        total: total,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      );
}

/// The listing under the current filters, page by page.
///
/// The first page loads whenever the filters change; the screen asks for the
/// next one with [EventsListController.loadMore] as the user scrolls down.
final eventsListProvider =
    AsyncNotifierProvider<EventsListController, EventsListState>(
      EventsListController.new,
    );

class EventsListController extends AsyncNotifier<EventsListState> {
  static const int pageSize = 10;

  /// A pause after a keystroke, so that typing a word sends one request.
  static const Duration searchDelay = Duration(milliseconds: 300);

  @override
  Future<EventsListState> build() async {
    final filters = ref.watch(eventFiltersProvider);
    if (filters.query.trim().isNotEmpty) {
      await Future<void>.delayed(searchDelay);
      // The user kept typing: this build has been replaced by a newer one.
      if (!ref.mounted) {
        return const EventsListState(items: [], page: 0, total: 0);
      }
    }

    final first = await _fetch(filters, 1);
    return EventsListState(
      items: first.items,
      page: first.page,
      total: first.total,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        state.isLoading ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );
    try {
      final next = await _fetch(
        ref.read(eventFiltersProvider),
        current.page + 1,
      );
      if (!ref.mounted) return;
      state = AsyncData(
        EventsListState(
          items: [...current.items, ...next.items],
          page: next.page,
          total: next.total,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  Future<PageResult<Event>> _fetch(EventFilters filters, int page) => ref
      .read(eventsRepositoryProvider)
      .fetchEvents(
        page: page,
        limit: pageSize,
        query: filters.query,
        category: filters.category,
      );
}

/// Publishing and deleting events. After either, the listing and the event
/// are loaded anew, so every screen shows the change.
final eventActionsProvider = Provider<EventActions>(EventActions.new);

class EventActions {
  EventActions(this._ref);

  final Ref _ref;

  EventsRepository get _repository => _ref.read(eventsRepositoryProvider);

  /// Uploads the poster first, if there is one, then publishes the event
  /// with its address.
  ///
  /// Throws [EventException] when the backend refuses either step.
  Future<Event> publish(
    EventDraft draft, {
    List<int>? posterBytes,
    String posterName = 'poster.jpg',
  }) async {
    var withPoster = draft;
    if (posterBytes != null) {
      final url = await _repository.uploadPoster(
        bytes: posterBytes,
        filename: posterName,
      );
      withPoster = draft.withImage(url);
    }
    final event = await _repository.createEvent(withPoster);
    _ref.invalidate(eventsListProvider);
    return event;
  }

  /// Throws [EventException] when the event cannot be deleted.
  Future<void> delete(String id) async {
    await _repository.deleteEvent(id);
    _ref
      ..invalidate(eventsListProvider)
      ..invalidate(eventByIdProvider(id));
  }
}
