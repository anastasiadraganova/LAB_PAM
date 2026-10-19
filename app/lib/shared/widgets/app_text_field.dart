import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// A text field with its label printed above it.
///
/// Focus is marked with a black outline rather than an ink one — ink is saved
/// for the two places that carry meaning. An error is black as well, with no
/// red anywhere.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = this.label;
    final errorText = this.errorText;

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: AppRadius.control,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: AppTypography.caption.copyWith(color: palette.grey),
          ),
          const SizedBox(height: Spacing.xxs),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          cursorColor: palette.black,
          style: AppTypography.body.copyWith(color: palette.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: palette.surface,
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: palette.grey),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: palette.grey),
            isDense: true,
            // The padding sits under the specified height, which is applied as
            // a minimum so the field only grows when the font is scaled up.
            constraints: const BoxConstraints(minHeight: AppSizes.control),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.sm,
            ),
            enabledBorder: border(
              errorText == null ? palette.rule : palette.black,
              errorText == null ? AppSizes.hairline : AppSizes.focusLine,
            ),
            focusedBorder: border(palette.black, AppSizes.focusLine),
            border: border(palette.rule, AppSizes.hairline),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: Spacing.xxs),
          Text(
            errorText,
            style: AppTypography.caption.copyWith(color: palette.black),
          ),
        ],
      ],
    );
  }
}
