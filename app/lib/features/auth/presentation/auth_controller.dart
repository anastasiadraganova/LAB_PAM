import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../shared/models/user.dart';
import '../domain/auth_repository.dart';

/// The session: who is signed in, and whether a sign-in is under way.
///
/// * `AsyncData(user)` — signed in; `AsyncData(null)` — signed out;
/// * `AsyncLoading` — the form has been sent and the answer is awaited;
/// * `AsyncError` — the last attempt was refused, the error says why.
///
/// The router listens to this state: a change of user moves the app between
/// the sign-in screen and the sections, no screen navigates by hand.
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);

/// The signed in user, or `null`, for everything that only needs the account.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authControllerProvider).value,
);

class AuthController extends AsyncNotifier<User?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// The session is known synchronously, so the very first state is already
  /// data and the router never has to wait for it.
  @override
  User? build() => ref.watch(authRepositoryProvider).currentUser;

  Future<void> signIn({required String email, required String password}) =>
      _run(() => _repository.signIn(email: email, password: password));

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) => _run(
    () => _repository.signUp(name: name, email: email, password: password),
  );

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncData(null);
  }

  /// Forgets the last refusal, for instance when the user edits the form.
  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }

  Future<void> _run(Future<User> Function() request) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(request);
    if (ref.mounted) state = result;
  }
}
