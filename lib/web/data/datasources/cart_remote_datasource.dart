import 'package:supabase_flutter/supabase_flutter.dart';

class CartRemoteDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getCartItems() async {
    return await _supabase
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', _userId!);
  }

  Future<Map<String, dynamic>?> getExistingCartItem(int productId) async {
    return await _supabase
        .from('cart_items')
        .select('id, quantity, cart_id')
        .eq('user_id', _userId!)
        .eq('product_id', productId)
        .maybeSingle();
  }

  Future<void> updateCartItemQuantity(int id, int quantity) async {
    await _supabase.from('cart_items').update({'quantity': quantity}).eq('id', id);
  }

  Future<Map<String, dynamic>?> getAnyCartItem() async {
    return await _supabase
        .from('cart_items')
        .select('cart_id')
        .eq('user_id', _userId!)
        .limit(1)
        .maybeSingle();
  }

  Future<void> insertCartItem(Map<String, dynamic> item) async {
    await _supabase.from('cart_items').insert(item);
  }

  Future<List<Map<String, dynamic>>> deleteCartItem(int cartId, int productId) async {
    return await _supabase
        .from('cart_items')
        .delete()
        .eq('id', cartId)
        .eq('product_id', productId)
        .eq('user_id', _userId!)
        .select();
  }

  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> payload) async {
    return await _supabase.from('orders').insert(payload).select().single();
  }

  Future<void> insertOrderItem(Map<String, dynamic> item) async {
    await _supabase.from('order_items').insert(item);
  }

  Future<Map<String, dynamic>?> getProfileName() async {
    return await _supabase.from('profiles').select('name').eq('id', _userId!).maybeSingle();
  }

  Future<Map<String, dynamic>> invokePaymobCheckout(Map<String, dynamic> body) async {
    final result = await _supabase.functions.invoke('paymob-checkout', body: body);
    return (result as FunctionResponse).data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    final uid = _supabase.auth.currentUser?.id;
    return await _supabase.from('orders').select().eq('user_id', uid!).order('created_at', ascending: false).limit(50);
  }

  Future<List<Map<String, dynamic>>> getSuggestedProducts(List<String> categories, {int limit = 20}) async {
    return await _supabase.from('products').select().inFilter('category', categories).limit(limit);
  }
}
