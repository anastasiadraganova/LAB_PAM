import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../formatters.dart';

/// Separator between the days of the listing: the date spelled out, then a
/// thin rule running off the edge of the screen. Today is set in ink.
class DayRule extends StatelessWidget {
  const DayRule({super.key, required this.date, this.isToday = false});

  final DateTime date;
  final bool isToday;

  /// The date takes the width it needs; the rule keeps at least this much, so
  /// that it always reads as a rule running off the edge.
  static const double _minRuleWidth = 24;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (constraints.maxWidth - Spacing.sm - _minRuleWidth)
                    .clamp(0.0, double.infinity),
              ),
              child: Text(
                Formatters.day(date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dayRule.copyWith(
                  color: isToday ? palette.ink : palette.black,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Container(
                height: AppSizes.hairline,
                color: palette.rule,
              ),
            ),
          ],
        );
      },
    );
  }
}
