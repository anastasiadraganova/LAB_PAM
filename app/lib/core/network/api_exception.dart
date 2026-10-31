import 'package:dio/dio.dart';

/// An error of the backend in its standard shape,
/// `{"error": {"code": "SOME_CODE", "message": "..."}}`, or a request that
/// never got an answer ([network]).
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  /// Turns whatever Dio threw into the standard shape.
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final body = response?.data;
    if (body is Map && body['error'] is Map) {
      final details = body['error'] as Map;
      return ApiException(
        code: '${details['code'] ?? unknown}',
        message: '${details['message'] ?? ''}',
        statusCode: response?.statusCode,
      );
    }
    if (response == null) {
      return ApiException(code: network, message: error.message ?? '');
    }
    return ApiException(
      code: unknown,
      message: error.message ?? '',
      statusCode: response.statusCode,
    );
  }

  // Codes of the course template.
  static const String validation = 'VALIDATION_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String emailTaken = 'EMAIL_TAKEN';

  // Codes of the client itself.
  static const String network = 'NETWORK';
  static const String unknown = 'UNKNOWN';

  final String code;

  /// The backend's text, in English: for logs, not for the screen.
  final String message;
  final int? statusCode;

  bool get isNetwork => code == network;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
