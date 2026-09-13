import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/model/user.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});
  Future<List<User>> getUsers({required int page, required int limit,String? search}) async {
    final response = await apiClient.get(
      '/users',
      queryparameter: {'_page': page, '_limit': limit,
      if(search != null && search.isNotEmpty) 'name_like':'Leanne',
      },
    );

    final List<dynamic> data = response.data;

    return data
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<User> createUser({required String name, required String email}) async {
    final response = await apiClient.post('/users', {
      'name': name,
      'email': email,
    });
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await apiClient.delete("/users/$id");
  }

  Future<User> updateUser({
    required int id,
    required String name,
    required String email,
  }) async {
    final response = await apiClient.put("/users/$id", {
      'name': name,
      'email': email,
    });
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}
