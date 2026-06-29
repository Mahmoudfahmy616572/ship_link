import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderMuteService {
  static const _key = 'muted_orders';

  Future<Set<String>> getMuted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw) as List);
  }

  Future<void> toggle(String orderId) async {
    final muted = await getMuted();
    if (muted.contains(orderId)) {
      muted.remove(orderId);
    } else {
      muted.add(orderId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(muted.toList()));
  }

  Future<bool> isMuted(String orderId) async {
    final muted = await getMuted();
    return muted.contains(orderId);
  }
}
