import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/validation/validators.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../domain/auth_repository.dart';
import 'auth_controller.dart';

/// Signing in and signing up share one screen and swap places on request.
///
/// Errors stay hidden until the first attempt to submit; after that they follow
/// the input as it is typed, so a fixed field clears its message at once.
///
/// What the fields hold is local to the screen. The request itself goes to
/// [AuthController]: while it runs the button is inactive, a refusal is printed
/// under the form, and success needs no handling here — the router sees the
/// new user and leaves this screen on its own.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isSignUp = false;
  bool _showErrors = false;

  String? get _nameError => _isSignUp ? Validators.name(_name.text) : null;
  String? get _emailError => Validators.email(_email.text);
  String? get _passwordError => Validators.password(_password.text);

  bool get _isValid =>
      _nameError == null && _emailError == null && _passwordError == null;

  AuthController get _auth => ref.read(authControllerProvider.notifier);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_isValid) {
      setState(() => _showErrors = true);
      return;
    }

    if (_isSignUp) {
      _auth.signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
    } else {
      _auth.signIn(email: _email.text, password: _password.text);
    }
  }

  void _toggleMode() {
    _auth.clearError();
    setState(() {
      _isSignUp = !_isSignUp;
      _showErrors = false;
    });
  }

  void _onChanged(String _) {
    _auth.clearError();
    if (_showErrors) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isSignUp = _isSignUp;
    final showErrors = _showErrors;

    final session = ref.watch(authControllerProvider);
    final isLoading = session.isLoading;
    final refusal = switch (session) {
      AsyncError(error: AuthException(:final message)) => message,
      AsyncError() => AppTexts.somethingWrong,
      _ => null,
    };

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
              AppTextField(
                label: AppTexts.fieldName,
                controller: _name,
                errorText: showErrors ? _nameError : null,
                textInputAction: TextInputAction.next,
                onChanged: _onChanged,
              ),
              const SizedBox(height: Spacing.md),
            ],
            AppTextField(
              label: AppTexts.fieldEmail,
              controller: _email,
              errorText: showErrors ? _emailError : null,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: _onChanged,
            ),
            const SizedBox(height: Spacing.md),
            AppTextField(
              label: AppTexts.fieldPassword,
              controller: _password,
              errorText: showErrors ? _passwordError : null,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onChanged: _onChanged,
              onSubmitted: (_) => _submit(),
            ),
            if (refusal != null) ...[
              const SizedBox(height: Spacing.md),
              Text(
                refusal,
                style: AppTypography.body.copyWith(color: palette.black),
              ),
            ],
            const SizedBox(height: Spacing.block),
            PrimaryButton(
              label: isSignUp ? AppTexts.signUp : AppTexts.signIn,
              onPressed: isLoading ? null : _submit,
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
                  onPressed: isLoading ? null : _toggleMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
