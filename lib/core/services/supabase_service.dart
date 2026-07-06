import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  Future<AuthResponse> signUp(String email, String password,
      {String? name}) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'name': name} : null,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authState => client.auth.onAuthStateChange;

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await client.from('products').select('*');
    return response;
  }

  Future<List<Map<String, dynamic>>> getTopSellers() async {
    final response = await client.from('products').select('*').eq('is_top_seller', true);
    return response;
  }

  Future<void> addToCart(int productId) async {
    final user = currentUser;
    if (user == null) return;
    await client.from('cart_items').upsert({
      'user_id': user.id,
      'product_id': productId,
      'quantity': 1,
    });
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final user = currentUser;
    if (user == null) return [];
    final response = await client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', user.id);
    return response;
  }

  Future<void> removeFromCart(int cartItemId) async {
    await client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await client.from('orders').insert(orderData);
  }

  Future<void> updateDriverLocation({
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    final user = currentUser;
    if (user == null) return;
    await client.from('driver_locations').upsert({
      'driver_id': user.id,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<Map<String, dynamic>> getDriverLocation(String driverId) {
    return client
        .from('driver_locations')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', driverId)
        .map((data) => data.isNotEmpty ? data.first : {});
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await client.from('orders').select('*');
    return response;
  }

  Future<void> acceptOrder(int orderId) async {
    await client.from('orders').update({'status': 'accepted'}).eq('id', orderId);
  }

  Future<List<Map<String, dynamic>>> getAcceptedOrders() async {
    final response =
        await client.from('orders').select('*').eq('status', 'accepted');
    return response;
  }

  Future<List<Map<String, dynamic>>> getProfilesByRole(String role) async {
    final response = await client
        .from('profiles')
        .select('*')
        .eq('role', role);
    return response;
  }

  Future<num> getTotalRevenue() async {
    final response = await client
        .from('orders')
        .select('total_price');
    num total = 0;
    for (final row in response) {
      total += (row['total_price'] as num? ?? 0);
    }
    return total;
  }

  Future<List<Map<String, dynamic>>> getOrdersGroupedByDate({int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final response = await client
        .from('orders')
        .select('total_price, created_at, status')
        .gte('created_at', since)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Returns the discount percent if [code] is valid & active, else null.
  Future<int?> verifyPromoCode(String code) async {
    final response = await client
        .from('promo_codes')
        .select('discount_percent, max_uses, current_uses, expires_at, is_active')
        .eq('code', code.toUpperCase())
        .limit(1)
        .maybeSingle();
    if (response == null) return null;
    if (response['is_active'] != true) return null;
    final maxUses = response['max_uses'] as int? ?? 0;
    final currentUses = response['current_uses'] as int? ?? 0;
    if (maxUses > 0 && currentUses >= maxUses) return null;
    final expiresAt = response['expires_at'] as String?;
    if (expiresAt != null && DateTime.parse(expiresAt).isBefore(DateTime.now())) return null;
    return response['discount_percent'] as int?;
  }
}
