import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../app_texts.dart';
import '../models/event_category.dart';

/// The row of category filters under the search field, with the date filter
/// sitting apart on the right.
///
/// A null [selected] means "Все".
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.selected,
    this.onSelected,
    this.onDatePressed,
    this.dateSelected = false,
  });

  final EventCategory? selected;
  final ValueChanged<EventCategory?>? onSelected;
  final VoidCallback? onDatePressed;
  final bool dateSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.minTouch,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
              children: [
                _Chip(
                  label: AppTexts.filterAll,
                  isSelected: selected == null,
                  onTap: onSelected == null ? null : () => onSelected!(null),
                ),
                for (final category in EventCategory.values)
                  _Chip(
                    label: category.title,
                    isSelected: selected == category,
                    onTap: onSelected == null
                        ? null
                        : () => onSelected!(category),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: Spacing.gutter),
          child: _DateFilterButton(
            isSelected: dateSelected,
            onTap: onDatePressed,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(right: Spacing.xs),
      child: Center(
        child: Material(
          color: isSelected ? palette.ink : Colors.transparent,
          borderRadius: AppRadius.chip,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.chip,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: AppRadius.chip,
                border: Border.all(
                  color: isSelected ? palette.ink : palette.rule,
                  width: AppSizes.hairline,
                ),
              ),
              child: Text(
                label,
                style: AppTypography.meta.copyWith(
                  color: isSelected ? AppPalette.onInk : palette.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: isSelected ? palette.ink : Colors.transparent,
      borderRadius: AppRadius.control,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.control,
        child: Container(
          width: AppSizes.minTouch,
          height: AppSizes.minTouch,
          decoration: BoxDecoration(
            borderRadius: AppRadius.control,
            border: Border.all(
              color: isSelected ? palette.ink : palette.rule,
              width: AppSizes.hairline,
            ),
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: isSelected ? AppPalette.onInk : palette.black,
          ),
        ),
      ),
    );
  }
}
