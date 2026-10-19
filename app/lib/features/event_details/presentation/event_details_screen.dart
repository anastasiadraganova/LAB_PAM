import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/formatters.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/date_stamp.dart';
import '../../../shared/widgets/event_poster.dart';

/// One event in full: poster, name, where and when, what it costs, and the way
/// to a ticket. Once the event has started, the button gives way to a line
/// saying so.
class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final today = DateTime.now();
    final isToday = event.day == DateTime(today.year, today.month, today.day);
    final isPast = event.isPast(now: today);

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              EventPoster(imageUrl: event.imageUrl, title: event.title),
              Positioned(
                top: AppSizes.stampInset,
                right: AppSizes.stampInset,
                child: DateStamp(date: event.dateTime, isToday: isToday),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.lg,
              Spacing.gutter,
              Spacing.block,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.posterXL.copyWith(color: palette.black),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  '${event.venue} · ${Formatters.dateAndTime(event.dateTime)}'
                  ' · ${event.category.value}',
                  style: AppTypography.meta.copyWith(color: palette.grey),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  Formatters.price(event.price),
                  style: AppTypography.price.copyWith(color: palette.black),
                ),
                const SizedBox(height: Spacing.block),
                Text(
                  event.description,
                  style: AppTypography.body.copyWith(color: palette.black),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.sm,
          Spacing.gutter,
          Spacing.md,
        ),
        child: isPast
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                child: Text(
                  AppTexts.eventIsPast,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: palette.grey),
                ),
              )
            : PrimaryButton(
                label: AppTexts.purchaseAction(isFree: event.isFree, qty: 1),
                onPressed: () => context.go(AppRoutes.purchase(event.id)),
              ),
      ),
    );
  }
}
