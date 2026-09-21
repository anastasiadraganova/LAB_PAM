import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../app_texts.dart';

/// Three sections along the bottom. The current one is told apart by colour and
/// by the weight of its label; there is no pill, no bubble, no background.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(AppTexts.sectionListing, Icons.local_activity_outlined),
    _NavItem(AppTexts.sectionTickets, Icons.confirmation_number_outlined),
    _NavItem(AppTexts.sectionProfile, Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: palette.rule, width: AppSizes.hairline),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var index = 0; index < _items.length; index++)
                Expanded(
                  child: _NavButton(
                    item: _items[index],
                    isSelected: index == currentIndex,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = isSelected ? palette.black : palette.grey;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: color, size: 24),
              const SizedBox(height: Spacing.xxs),
              Text(
                item.label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
