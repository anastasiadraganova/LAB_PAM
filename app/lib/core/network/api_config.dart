import 'package:flutter/foundation.dart';

/// Where the backend is.
///
/// Set it at build time: `flutter run --dart-define=API_URL=http://192.168.1.5:8080`.
/// Without it the app uses the backend on this computer — `localhost`, or
/// `10.0.2.2` from the Android emulator, which is how the emulator sees the
/// host machine.
abstract final class ApiConfig {
  static const String _fromEnvironment = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_fromEnvironment.isNotEmpty) return _fromEnvironment;
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  }

  /// The backend returns its own files as paths (`/files/7`); everything else
  /// is already a full address.
  static String resolve(String url) =>
      url.startsWith('/') ? '$baseUrl$url' : url;
}
