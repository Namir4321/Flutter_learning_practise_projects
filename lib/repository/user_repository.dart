import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/service/user_cache_service.dart';
import 'package:dio/dio.dart';

class UserRepository {
  final ApiClient apiClient;
  final UserCacheService userCacheService;

  UserRepository({required this.apiClient, required this.userCacheService});
  Future<List<User>> getUsers({
    required int page,
    required int limit,
    String? search,
    CancelToken? cancelToken,
  }) async {
    final response = await apiClient.get(
      '/users',
      queryparameter: {
        '_page': page,
        '_limit': limit,
        if (search != null && search.isNotEmpty) 'name_like': 'Leanne',
      },
      cancelToken: cancelToken,
    );
    final List<dynamic> data = response.data;

    final users = data
        .map((element) => User.fromJson(element as Map<String, dynamic>))
        .toList();
    if (page == 1 && (search == null || search.isEmpty)) {
      await userCacheService.saveUsers(users);
    }
    return users;
  }

  //   return data
  //       .map((json) => User.fromJson(json as Map<String, dynamic>))
  //       .toList();
  // }

  Future<List<User>> getCachedUsers() async {
    final cacheduserlist = await userCacheService.getUsers();
    return cacheduserlist;
  }

  Future<User> getUserById(int id) async {
    final response = await apiClient.get('/users/$id');
    return User.fromJson(response.data as Map<String, dynamic>);
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
