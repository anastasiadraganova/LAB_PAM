import '../../../shared/app_texts.dart';
import '../../../shared/models/user.dart';
import '../../profile/data/demo_user.dart';
import '../domain/auth_repository.dart';

/// [AuthRepository] with the accounts kept in memory.
///
/// One account exists from the start — the demo user with [demoPassword].
/// Accounts created through sign-up live until the app is closed.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.latency = const Duration(milliseconds: 400),
    User? signedIn,
  }) : _currentUser = signedIn {
    _accounts[_key(demoUser.email)] = (user: demoUser, password: demoPassword);
  }

  final Duration latency;

  final Map<String, ({User user, String password})> _accounts = {};
  User? _currentUser;
  int _lastId = 1;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User> signIn({required String email, required String password}) async {
    await _wait();

    final account = _accounts[_key(email)];
    if (account == null || account.password != password) {
      throw const AuthException(AppTexts.wrongCredentials);
    }
    return _currentUser = account.user;
  }

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _wait();

    final key = _key(email);
    if (_accounts.containsKey(key)) {
      throw const AuthException(AppTexts.emailTaken);
    }

    _lastId++;
    final user = User(id: 'u$_lastId', name: name.trim(), email: email.trim());
    _accounts[key] = (user: user, password: password);
    return _currentUser = user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  /// Emails are compared without case and surrounding spaces.
  static String _key(String email) => email.trim().toLowerCase();

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }
}
