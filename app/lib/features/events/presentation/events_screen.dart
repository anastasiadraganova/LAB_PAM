import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/day_rule.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/filter_chips.dart';
import '../data/demo_events.dart';

/// The listing: search, category filters and the events themselves, gathered
/// into days under a printed rule.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventCategory? _category;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final events = _visibleEvents();
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header(context)),
          if (events.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(message: AppTexts.emptyListing),
            )
          else
            SliverList.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final isFirstOfDay =
                    index == 0 || events[index - 1].day != event.day;

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.gutter,
                      ),
                      child: EventCard(
                        event: event,
                        onTap: () => _openEvent(event),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.block)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final palette = context.palette;

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
            prefixIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        FilterChips(
          selected: _category,
          onSelected: (category) => setState(() => _category = category),
        ),
        const SizedBox(height: Spacing.block),
      ],
    );
  }

  List<Event> _visibleEvents() {
    final query = _query.trim().toLowerCase();

    return demoEvents.where((event) {
      final matchesCategory = _category == null || event.category == _category;
      final matchesQuery =
          query.isEmpty || event.title.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  void _openEvent(Event event) {
    context.go(AppRoutes.event(event.id));
  }
}
