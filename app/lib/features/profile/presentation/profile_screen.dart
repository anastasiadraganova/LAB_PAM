import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../data/demo_user.dart';

/// Who is signed in, and the one way out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.md,
          Spacing.gutter,
          Spacing.block,
        ),
        children: [
          Text(
            AppTexts.titleProfile,
            style: AppTypography.posterXL.copyWith(color: palette.black),
          ),
          const SizedBox(height: Spacing.block),
          _Field(label: AppTexts.fieldName, value: demoUser.name),
          const SizedBox(height: Spacing.md),
          _Field(label: AppTexts.fieldEmail, value: demoUser.email),
          const SizedBox(height: Spacing.xxl),
          DangerButton(
            label: AppTexts.signOut,
            note: AppTexts.signOutNote,
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: palette.grey),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          value,
          style: AppTypography.body.copyWith(color: palette.black),
        ),
      ],
    );
  }
}
