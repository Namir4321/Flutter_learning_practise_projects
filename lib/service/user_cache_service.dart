import 'dart:convert';

import 'package:basic_widget/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCacheService {
  static const String _usersKey = 'cached_users';

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();

    final userMaps = users.map((user) => user.toJson()).toList();

    final encodedUsers = jsonEncode(userMaps);

    await prefs.setString(_usersKey, encodedUsers);
  }

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedUser = prefs.getString(_usersKey);
    if (encodedUser == null) {
      return [];
    }
    final decodeUsers = jsonDecode(encodedUser);
    return decodeUsers
        .map((userlist) => User.fromJson(userlist as Map<String, dynamic>))
        .toList();
  }
}
