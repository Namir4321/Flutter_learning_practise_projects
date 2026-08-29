import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/bloc/network/api_exception.dart';
import 'package:basic_widget/model/auth_response.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      await apiClient.post('/users', {'email': email, 'password': password});

      return const AuthResponse(
        accessToken: 'fake_access_token',
        refreshToken: 'fake_refresh_token',
      );
    } on DioException catch (error) {
      if (error.error is ApiException) {
        throw error.error as ApiException;
      }

      rethrow;
    }
  }
}
