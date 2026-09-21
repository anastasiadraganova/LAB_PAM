import 'package:flutter/material.dart';

import '../../core/theme/spacing.dart';

/// The frame of a stamp: a bare outlined rectangle, tilted, with nothing
/// behind it.
///
/// Two places in the application use it and no more — the date on a poster and
/// the "погашен" mark across a spent ticket.
class StampFrame extends StatelessWidget {
  const StampFrame({
    super.key,
    required this.color,
    required this.tilt,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.xs,
      vertical: Spacing.xxs,
    ),
  });

  final Color color;

  /// Rotation in radians.
  final double tilt;

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: AppSizes.stampLine),
        ),
        child: child,
      ),
    );
  }
}
