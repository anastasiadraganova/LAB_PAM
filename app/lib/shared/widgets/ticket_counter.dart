import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../app_texts.dart';

/// Minus, the number, plus — with the hint about the upper limit underneath.
///
/// At the ends of the range the matching button goes inactive, and at ten the
/// hint spells the rule out in full.
class TicketCounter extends StatelessWidget {
  const TicketCounter({
    super.key,
    required this.qty,
    this.onChanged,
    this.minQty = 1,
    this.maxQty = 10,
  });

  final int qty;
  final ValueChanged<int>? onChanged;
  final int minQty;
  final int maxQty;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canDecrease = qty > minQty;
    final canIncrease = qty < maxQty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CounterButton(
              icon: Icons.remove,
              isEnabled: canDecrease,
              onTap: canDecrease && onChanged != null
                  ? () => onChanged!(qty - 1)
                  : null,
            ),
            Expanded(
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: AppTypography.posterXL.copyWith(color: palette.black),
              ),
            ),
            _CounterButton(
              icon: Icons.add,
              isEnabled: canIncrease,
              onTap: canIncrease && onChanged != null
                  ? () => onChanged!(qty + 1)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          canIncrease ? AppTexts.quantityHint : AppTexts.quantityLimit,
          style: AppTypography.caption.copyWith(
            color: canIncrease ? palette.grey : palette.black,
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  final IconData icon;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = isEnabled ? palette.black : palette.rule;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.control,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.control,
        child: Container(
          width: AppSizes.control,
          height: AppSizes.control,
          decoration: BoxDecoration(
            borderRadius: AppRadius.control,
            border: Border.all(color: color, width: AppSizes.focusLine),
          ),
          child: Icon(
            icon,
            color: isEnabled ? palette.black : palette.grey,
            size: 24,
          ),
        ),
      ),
    );
  }
}
