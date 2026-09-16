import 'package:basic_widget/bloc/network/api_error_handler.dart';
import 'package:basic_widget/data/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final Dio dio;
  final SecureStorage secureStorage;
  VoidCallback? onSessionExpired;
  Future<String?>? _refreshFuture;

  Future<String?> _getRefreshedToken() async {
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }
    _refreshFuture ??= refreshAccessToken();

    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryparameter,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryparameter,
        cancelToken: cancelToken,
      );
    } on DioException catch (err) {
      if (err.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw ApiErrorHandler.handle(err);
    }
  }

  Future<Response<dynamic>> post(
    String path,
    dynamic data, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await dio.post(path, data: data, onSendProgress: onSendProgress);
    } on DioException catch (err) {
      throw ApiErrorHandler.handle(err);
    }
  }

  Future<Response<dynamic>> put(String path, dynamic data) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (err) {
      throw ApiErrorHandler.handle(err);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (err) {
      throw ApiErrorHandler.handle(err);
    }
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await secureStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        return null;
      }

      await secureStorage.saveAccessToken(newAccessToken);

      return newAccessToken;
    } on DioException {
      return null;
    }
  }

  ApiClient({Dio? dio, required this.secureStorage})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com/',

              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.getAccessToken();

          // Only add Authorization header for real APIs, not for public endpoints
          if (token != null &&
              token.isNotEmpty &&
              !options.uri.toString().contains('jsonplaceholder')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          final isRefreshRequest = error.requestOptions.path.contains(
            'auth/refresh',
          );

          if (error.response?.statusCode == 401 && !isRefreshRequest) {
            debugPrint('401 DETECTED');

            final newAccessToken = await _getRefreshedToken();

            if (newAccessToken != null) {
              debugPrint('ACCESS TOKEN REFRESHED');

              final requestOptions = error.requestOptions;

              requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              final response = await this.dio.fetch(requestOptions);

              return handler.resolve(response);
            } else {
              debugPrint('TOKEN REFRESH FAILED');
              await secureStorage.clearTokens();
              onSessionExpired?.call();
            }
          }

          final apiException = ApiErrorHandler.handle(error);

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: apiException,
            ),
          );
        },
      ),
    );
  }
}
