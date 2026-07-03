import 'package:shared_preferences/shared_preferences.dart';

class WebCacheService {
  static final WebCacheService _instance = WebCacheService._();
  factory WebCacheService() => _instance;
  WebCacheService._();

  Future<void> put(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
