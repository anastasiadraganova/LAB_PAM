import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../auth/presentation/auth_controller.dart';

/// Who is signed in, and the one way out.
///
/// The account comes from the session state. Signing out only clears the
/// session; the router notices and returns to the sign-in screen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

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
          _Field(label: AppTexts.fieldName, value: user.name),
          const SizedBox(height: Spacing.md),
          _Field(label: AppTexts.fieldEmail, value: user.email),
          const SizedBox(height: Spacing.xxl),
          DangerButton(
            label: AppTexts.signOut,
            note: AppTexts.signOutNote,
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
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
        Text(label, style: AppTypography.caption.copyWith(color: palette.grey)),
        const SizedBox(height: Spacing.xxs),
        Text(value, style: AppTypography.body.copyWith(color: palette.black)),
      ],
    );
  }
}
