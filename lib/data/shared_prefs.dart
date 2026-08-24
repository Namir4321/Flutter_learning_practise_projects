import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  Future<void> removeName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
  }

  Future<void> saveLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', value);
  }

  Future<bool?> getLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn');
  }

  Future<void> saveScore(double score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('score', score);
  }

  Future<double?> getScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('score');
  }
}