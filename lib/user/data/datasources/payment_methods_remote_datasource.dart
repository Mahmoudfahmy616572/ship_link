import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentMethodsRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAll(String userId) async {
    return await _supabase
        .from('payment_methods')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
  }

  Future<void> clearDefaults(String userId) async {
    await _supabase.from('payment_methods').update({'is_default': false}).eq('user_id', userId);
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _supabase.from('payment_methods').insert(data);
  }

  Future<void> setDefault(String id) async {
    await _supabase.from('payment_methods').update({'is_default': true}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('payment_methods').delete().eq('id', id);
  }
}
