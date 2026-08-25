import 'dart:convert';
import 'package:basic_widget/model/auth_response.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 201) {
      return const AuthResponse(
        accessToken: 'fake_acess_token',
        refreshToken: 'fake_response_token',
      );
    }
    throw Exception('Login Failed');
  }
}
