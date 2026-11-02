import '../../../shared/models/user.dart';

/// Sign-in or sign-up refused; [message] is ready to be shown under the form.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Accounts and the current session.
abstract interface class AuthRepository {
  /// Who is signed in right now, or `null`. Known synchronously: the session
  /// is restored before the first frame.
  User? get currentUser;

  /// Brings back the session saved on the device, if there is one and the
  /// backend still accepts it. Called once, before the first frame.
  Future<void> restoreSession();

  /// Throws [AuthException] when the email and password do not match.
  Future<User> signIn({required String email, required String password});

  /// Creates the account and signs into it.
  ///
  /// Throws [AuthException] when the email is already taken.
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
