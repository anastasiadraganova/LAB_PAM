import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value store for what the app keeps between launches: the last
/// loaded listing, the user's tickets and the signed in account. Values are
/// JSON strings.
abstract interface class LocalCache {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

/// The cache on the device: SharedPreferences (NSUserDefaults on iOS,
/// SharedPreferences on Android, localStorage on the web).
class PreferencesCache implements LocalCache {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

/// For tests: lives only as long as the object.
class MemoryCache implements LocalCache {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}
