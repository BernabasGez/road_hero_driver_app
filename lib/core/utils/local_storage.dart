import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
  }
}
