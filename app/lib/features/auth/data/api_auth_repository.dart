import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/user.dart';
import '../domain/auth_repository.dart';

/// [AuthRepository] over the backend: `POST /auth/login`,
/// `POST /auth/register` and `GET /me`. The JWT the backend issues is kept in
/// the client's token storage, so the session survives a restart.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);

  final ApiClient _api;
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<void> restoreSession() async {
    if (await _api.tokens.read() == null) return;
    try {
      _currentUser = _user(await _api.get('/me'));
    } on ApiException catch (error) {
      // A rejected token is gone for good; without a network the token is
      // kept and the user simply signs in again.
      if (!error.isNetwork) await _api.tokens.clear();
    }
  }

  @override
  Future<User> signIn({required String email, required String password}) =>
      _authenticate('/auth/login', {
        'email': email.trim(),
        'password': password,
      });

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) => _authenticate('/auth/register', {
    'name': name.trim(),
    'email': email.trim(),
    'password': password,
  });

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _api.tokens.clear();
  }

  /// Both endpoints answer `{token, user}`.
  Future<User> _authenticate(String path, Map<String, Object?> body) async {
    final Map<String, dynamic> json;
    try {
      json = await _api.post(path, body);
    } on ApiException catch (error) {
      throw AuthException(switch (error.code) {
        ApiException.unauthorized => AppTexts.wrongCredentials,
        ApiException.emailTaken => AppTexts.emailTaken,
        ApiException.network => AppTexts.networkError,
        _ => AppTexts.somethingWrong,
      });
    }

    await _api.tokens.write(json['token'] as String);
    return _currentUser = _user(json['user'] as Map<String, dynamic>);
  }

  static User _user(Map<String, dynamic> json) => User(
    id: '${json['id']}',
    name: json['name'] as String,
    email: json['email'] as String,
  );
}
