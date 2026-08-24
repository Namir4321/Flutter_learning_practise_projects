import 'package:basic_widget/model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRepository {
  Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;

      final users = data.map((json) => User.fromJson(json)).toList();
      return users;
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<User> createUser({required String name, required String email}) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Failed to create user");
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse("https://jsonplaceholder.typicode.com/users/$id"),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete the user");
    }
  }

  Future<User> updateUser({
    required int id,
    required String name,
    required String email,
  }) async {
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return User.fromJson(data);
    } else {
      throw Exception('Failed to update user');
    }
  }
}
