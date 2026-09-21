import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';

/// Signing in and signing up share one screen and swap places on request.
/// The fields carry no rules yet; validation arrives with the next stage.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.onSubmit});

  final VoidCallback? onSubmit;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isSignUp = _isSignUp;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.xxl,
            Spacing.gutter,
            Spacing.block,
          ),
          children: [
            Text(
              isSignUp ? AppTexts.titleSignUp : AppTexts.titleSignIn,
              style: AppTypography.posterXL.copyWith(color: palette.black),
            ),
            const SizedBox(height: Spacing.block),
            if (isSignUp) ...[
              const AppTextField(
                label: AppTexts.fieldName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: Spacing.md),
            ],
            const AppTextField(
              label: AppTexts.fieldEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            const AppTextField(
              label: AppTexts.fieldPassword,
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: Spacing.block),
            PrimaryButton(
              label: isSignUp ? AppTexts.signUp : AppTexts.signIn,
              onPressed: widget.onSubmit,
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    isSignUp ? AppTexts.hasAccount : AppTexts.noAccount,
                    style: AppTypography.body.copyWith(color: palette.grey),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                AppTextButton(
                  label: isSignUp ? AppTexts.goToSignIn : AppTexts.goToSignUp,
                  onPressed: () => setState(() => _isSignUp = !isSignUp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
