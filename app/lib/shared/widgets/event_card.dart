import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../formatters.dart';
import '../models/event.dart';
import 'date_stamp.dart';
import 'event_poster.dart';

/// An event in the listing: poster with the date stamped into its corner, then
/// the title, one line of meta and the price.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final today = DateTime.now();
    final isToday = event.day ==
        DateTime(today.year, today.month, today.day);

    return Material(
      color: palette.surface,
      borderRadius: AppRadius.print,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.print,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.print,
            border: Border.all(
              color: palette.rule,
              width: AppSizes.hairline,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  EventPoster(
                    imageUrl: event.imageUrl,
                    title: event.title,
                  ),
                  Positioned(
                    top: AppSizes.stampInset,
                    right: AppSizes.stampInset,
                    child: DateStamp(date: event.dateTime, isToday: isToday),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.poster.copyWith(
                        color: palette.black,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      _metaLine(event),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.meta.copyWith(color: palette.grey),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      Formatters.price(event.price),
                      style: AppTypography.price.copyWith(
                        color: palette.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _metaLine(Event event) {
    return '${event.venue} · ${Formatters.time(event.dateTime)}'
        ' · ${event.category.value}';
  }
}
