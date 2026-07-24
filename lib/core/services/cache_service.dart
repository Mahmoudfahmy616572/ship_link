import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._();
  factory CacheService() => _instance;
  CacheService._();

  Future<void> put(String key, dynamic data, {Duration ttl = const Duration(minutes: 30)}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_$key', jsonEncode(data));
    await prefs.setInt('cache_${key}_ts', DateTime.now().millisecondsSinceEpoch + ttl.inMilliseconds);
  }

  Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt('cache_${key}_ts');
    if (ts == null || DateTime.now().millisecondsSinceEpoch > ts) {
      await prefs.remove('cache_$key');
      await prefs.remove('cache_${key}_ts');
      return null;
    }
    final raw = prefs.getString('cache_$key');
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cache_$key');
    await prefs.remove('cache_${key}_ts');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

class CredentialsService {
  static final CredentialsService _instance = CredentialsService._();
  factory CredentialsService() => _instance;
  CredentialsService._();

  Future<void> save(String email, {String? password}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    if (password != null) {
      await prefs.setString('saved_password', password);
    }
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email');
  }

  Future<String?> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email');
  }

  Future<String?> loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_password');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }
}
