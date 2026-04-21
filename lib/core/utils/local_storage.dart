import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static const _storage = FlutterSecureStorage();
  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    print("Tokens saved successfully!"); // Add this to verify in logs
  }

  static Future<String?> getAccessToken() async =>
      _storage.read(key: _accessKey);

  // Add this alias to fix the errors in your repositories
  static Future<String?> getToken() async => getAccessToken();

  static Future<String?> getRefreshToken() async =>
      _storage.read(key: _refreshKey);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  // Add this alias
  static Future<void> clear() async => clearTokens();

  static Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessKey);
    return token != null && token.length > 10; // Simple check for a real JWT
  }
}
