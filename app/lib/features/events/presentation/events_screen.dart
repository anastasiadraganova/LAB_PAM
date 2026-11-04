import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/day_rule.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/filter_chips.dart';
import '../../../shared/widgets/loading_state.dart';
import 'events_providers.dart';

/// The listing: search, category filters and the events themselves, gathered
/// into days under a printed rule.
///
/// The events and the filters both live in providers: the screen only shows
/// [eventsListProvider] and reports what the user picks. The backend filters
/// and pages the listing; the next page loads as the end comes into view.
/// The filters survive switching sections; pull to refresh starts over.
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  /// Holds the text of the search field so that "reset" can clear it too.
  late final _search = TextEditingController(
    text: ref.read(eventFiltersProvider).query,
  );

  EventFiltersController get _filters =>
      ref.read(eventFiltersProvider.notifier);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _search.clear();
    _filters.reset();
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsListProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(eventsListProvider.future),
        // Near the end of what is loaded, the next page is requested.
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 600) {
              ref.read(eventsListProvider.notifier).loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              ...switch (events) {
                AsyncError() => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      message: AppTexts.listingError,
                      action: AppTextButton(
                        label: AppTexts.retry,
                        onPressed: () => ref.invalidate(eventsListProvider),
                      ),
                    ),
                  ),
                ],
                AsyncValue(:final value?) when value.items.isEmpty => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      message: AppTexts.emptyListing,
                      action: AppTextButton(
                        label: AppTexts.resetFilters,
                        onPressed: _resetFilters,
                      ),
                    ),
                  ),
                ],
                AsyncValue(:final value?) => [
                  _EventList(events: value.items),
                  SliverToBoxAdapter(child: _NextPage(state: value)),
                ],
                _ => [
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingState(),
                  ),
                ],
              },
              const SliverToBoxAdapter(child: SizedBox(height: Spacing.block)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final palette = context.palette;
    final category = ref.watch(
      eventFiltersProvider.select((filters) => filters.category),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: Text(
            AppTexts.titleListing,
            style: AppTypography.posterXL.copyWith(color: palette.black),
          ),
        ),
        const SizedBox(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: AppTextField(
            hint: AppTexts.searchHint,
            controller: _search,
            prefixIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onChanged: _filters.setQuery,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        FilterChips(selected: category, onSelected: _filters.setCategory),
        const SizedBox(height: Spacing.block),
      ],
    );
  }
}

/// Under the last loaded card: a spinner while the next page is on its way,
/// or a way to ask for it again after a failure.
class _NextPage extends ConsumerWidget {
  const _NextPage({required this.state});

  final EventsListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.only(top: Spacing.block),
        child: LoadingState(),
      );
    }
    if (state.loadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.only(top: Spacing.md),
        child: EmptyState(
          message: AppTexts.listingError,
          action: AppTextButton(
            label: AppTexts.retry,
            onPressed: () => ref.read(eventsListProvider.notifier).loadMore(),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return SliverList.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isFirstOfDay = index == 0 || events[index - 1].day != event.day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isFirstOfDay) ...[
              SizedBox(height: index == 0 ? 0 : Spacing.block),
              Padding(
                padding: const EdgeInsets.only(left: Spacing.gutter),
                child: DayRule(
                  date: event.day,
                  isToday: event.day == startOfToday,
                ),
              ),
              const SizedBox(height: Spacing.sm),
            ] else
              const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
              child: EventCard(
                event: event,
                onTap: () => context.go(AppRoutes.event(event.id)),
              ),
            ),
          ],
        );
      },
    );
  }
}
