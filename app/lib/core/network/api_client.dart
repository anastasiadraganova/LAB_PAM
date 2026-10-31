import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'token_storage.dart';

/// HTTP access to the backend: base address, the JWT on every request, and
/// errors in one shape.
///
/// Every method throws [ApiException] and nothing else, so repositories only
/// ever deal with the error format of the course template.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.tokens,
    this.onUnauthorized,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15)
      ..contentType = Headers.jsonContentType;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokens.read();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          // A token that expired or was revoked: the session is over. The
          // sign-in request itself answers 401 for a wrong password, which is
          // not an expired session.
          final isSignIn = error.requestOptions.path.startsWith('/auth/');
          if (error.response?.statusCode == 401 && !isSignIn) {
            await tokens.clear();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage tokens;

  /// Called when the backend rejects the saved token.
  final void Function()? onUnauthorized;

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send(() => _dio.get<Object?>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(String path, [Object? body]) =>
      _send(() => _dio.post<Object?>(path, data: body));

  Future<Map<String, dynamic>> put(String path, Object? body) =>
      _send(() => _dio.put<Object?>(path, data: body));

  Future<void> delete(String path) => _send(() => _dio.delete<Object?>(path));

  /// `POST /files` as multipart, field `file`; answers `{id, url, ...}`.
  Future<Map<String, dynamic>> upload(
    String path, {
    required List<int> bytes,
    required String filename,
  }) => _send(
    () => _dio.post<Object?>(
      path,
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    ),
  );

  Future<Map<String, dynamic>> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      return data is Map<String, dynamic> ? data : const {};
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
