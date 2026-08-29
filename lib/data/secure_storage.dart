import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage;

  const SecureStorage({this.storage = const FlutterSecureStorage()});

  Future<void> saveAccessToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return storage.read(key: 'access_token');
    
  }

  Future<void> saveRefreshToken(String token) async {
    return storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return storage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }
}
