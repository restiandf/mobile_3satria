import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const String _tokenKey = 'auth_token';
  // Menyimpan token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Mengambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Menghapus token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Cek status login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
