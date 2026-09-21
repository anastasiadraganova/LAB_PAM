import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// The one filled button in the application: ink, white label.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEnabled = onPressed != null;

    return _ButtonShell(
      onPressed: onPressed,
      fill: isEnabled ? palette.ink : palette.rule,
      border: null,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.button.copyWith(
          color: isEnabled ? AppPalette.onInk : palette.grey,
        ),
      ),
    );
  }
}

/// Outlined, unfilled, black.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return _ButtonShell(
      onPressed: onPressed,
      fill: Colors.transparent,
      border: Border.all(color: palette.black, width: AppSizes.focusLine),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.button.copyWith(color: palette.black),
      ),
    );
  }
}

/// An action that cannot be taken back. No fill, no outline, and a line of
/// explanation printed underneath so the consequence is stated before the tap.
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.note,
    this.onPressed,
  });

  final String label;
  final String note;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ButtonShell(
          onPressed: onPressed,
          fill: Colors.transparent,
          border: null,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.button.copyWith(color: palette.black),
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          note,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: palette.grey),
        ),
      ],
    );
  }
}

/// Underlined ink text, for the quiet way out of a screen.
class AppTextButton extends StatelessWidget {
  const AppTextButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.control,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.control,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: palette.ink,
                    decoration: TextDecoration.underline,
                    decorationColor: palette.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared geometry of the three block buttons: full width, 52 high, radius 8.
/// The height is a minimum so a scaled up system font still fits.
class _ButtonShell extends StatelessWidget {
  const _ButtonShell({
    required this.onPressed,
    required this.fill,
    required this.border,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Color fill;
  final BoxBorder? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fill,
      borderRadius: AppRadius.control,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.control,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.control),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.control,
            border: border,
          ),
          // A row rather than an alignment: the button takes the full width it
          // is offered but only as much height as the label needs.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Flexible(child: child)],
          ),
        ),
      ),
    );
  }
}
