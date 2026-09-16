import 'package:basic_widget/bloc/network/api_exception.dart';
import 'package:dio/dio.dart';

class ApiErrorHandler {
  static ApiException handle(DioException error) {
    // Network / timeout errors first
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(message: 'Connection timed out. Please try again.');

      case DioExceptionType.sendTimeout:
        return ApiException(message: 'Request timed out while sending data.');

      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Server took too long to respond.');

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect. Check your internet connection.',
        );
      case DioExceptionType.cancel:
        return ApiException(message: "Request Cancelled");
      default:
        break;
    }

    // Server responded, so check HTTP status code
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 400:
        return ApiException(message: 'Bad request', statusCode: 400);

      case 401:
        return ApiException(
          message: 'Invalid email or password',
          statusCode: 401,
        );

      case 403:
        return ApiException(
          message: 'You do not have permission',
          statusCode: 403,
        );

      case 404:
        return ApiException(message: 'Resource not found', statusCode: 404);

      case 500:
        return ApiException(
          message: 'Server error. Please try again later.',
          statusCode: 500,
        );

      default:
        return ApiException(
          message: 'Something went wrong',
          statusCode: statusCode,
        );
    }
  }
}
