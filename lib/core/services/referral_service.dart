import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReferralService {
  final _supabase = Supabase.instance.client;

  String generateCode([int length = 8]) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<String> ensureCode(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select('code')
        .eq('id', userId)
        .maybeSingle();
    if (data != null && data['code'] != null && (data['code'] as String).isNotEmpty) {
      return data['code'] as String;
    }
    final code = generateCode();
    await _supabase.from('profiles').upsert({'id': userId, 'code': code});
    return code;
  }

  Future<Map<String, dynamic>?> lookupByCode(String code) async {
    final data = await _supabase
        .from('profiles')
        .select('id, name')
        .eq('code', code.toUpperCase())
        .maybeSingle();
    return data;
  }

  String shareText(String code) {
    return 'Use my referral code "$code" on ShipLink to get started! Download at: https://shiplink.app/download';
  }
}
