import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<void> saveUserData(String data) =>
      _storage.write(key: _userKey, value: data);

  Future<String?> getUserData() => _storage.read(key: _userKey);

  Future<void> deleteUserData() => _storage.delete(key: _userKey);

  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
