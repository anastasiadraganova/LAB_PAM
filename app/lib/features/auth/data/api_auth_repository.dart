import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_cache.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/user.dart';
import '../domain/auth_repository.dart';

/// [AuthRepository] over the backend: `POST /auth/login`,
/// `POST /auth/register` and `GET /me`. The JWT the backend issues is kept in
/// the client's token storage, so the session survives a restart. The
/// account itself is cached too: without a network the app opens signed in,
/// on the copies of the listing and tickets it loaded last time.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, [this._cache]);

  static const String _userKey = 'cache.user';

  final ApiClient _api;
  final LocalCache? _cache;
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<void> restoreSession() async {
    if (await _api.tokens.read() == null) return;
    try {
      _currentUser = await _remember(_user(await _api.get('/me')));
    } on ApiException catch (error) {
      if (error.isNetwork) {
        // No network: stay signed in as the account saved last time.
        final raw = await _cache?.read(_userKey);
        if (raw != null) {
          _currentUser = _user(jsonDecode(raw) as Map<String, dynamic>);
        }
      } else {
        // A rejected token is gone for good.
        await _api.tokens.clear();
        await _cache?.remove(_userKey);
      }
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

  /// Forgets the token and everything cached for this account.
  @override
  Future<void> signOut() async {
    final user = _currentUser;
    _currentUser = null;
    await _api.tokens.clear();
    await _cache?.remove(_userKey);
    if (user != null) await _cache?.remove('cache.tickets.${user.id}');
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
    return _currentUser = await _remember(
      _user(json['user'] as Map<String, dynamic>),
    );
  }

  Future<User> _remember(User user) async {
    await _cache?.write(
      _userKey,
      jsonEncode({'id': user.id, 'name': user.name, 'email': user.email}),
    );
    return user;
  }

  static User _user(Map<String, dynamic> json) => User(
    id: '${json['id']}',
    name: json['name'] as String,
    email: json['email'] as String,
  );
}
