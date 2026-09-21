import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../app_texts.dart';
import '../formatters.dart';
import 'stamp.dart';

/// The date printed into the corner of a poster.
///
/// Two lines inside an ink outline, tilted like a real impression. An event
/// that happens today carries a fluo dot and the word "сегодня" beside it.
class DateStamp extends StatelessWidget {
  const DateStamp({super.key, required this.date, this.isToday = false});

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final stampStyle = AppTypography.stamp.copyWith(color: palette.ink);

    final stamp = StampFrame(
      color: palette.ink,
      tilt: AppSizes.dateStampTilt,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(Formatters.stampDay(date), style: stampStyle),
          Text(Formatters.stampMonth(date), style: stampStyle),
        ],
      ),
    );

    if (!isToday) return stamp;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Spacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.statusDot,
                height: AppSizes.statusDot,
                decoration: BoxDecoration(
                  color: palette.fluo,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Spacing.xxs),
              Text(
                AppTexts.today,
                style: AppTypography.caption.copyWith(color: palette.ink),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xs),
        stamp,
      ],
    );
  }
}
