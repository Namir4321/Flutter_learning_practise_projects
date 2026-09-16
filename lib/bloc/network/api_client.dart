import 'package:basic_widget/bloc/network/api_error_handler.dart';
import 'package:basic_widget/data/secure_storage.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  final SecureStorage secureStorage;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryparameter,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryparameter);
    } on DioException catch (err) {
      throw ApiErrorHandler.handle(err);
    }
  }

  Future<Response<dynamic>> post(String path, dynamic data, {ProgressCallback? onSendProgress}) async {
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

  ApiClient({Dio? dio, required this.secureStorage})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com/',

              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
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
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }
}
