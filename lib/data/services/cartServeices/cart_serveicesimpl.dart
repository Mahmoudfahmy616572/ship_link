import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/data/models/payment/payment.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveices.dart';
import 'package:ship_link/services/cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartServeicesImpl extends CartServeices {
  CartServeicesImpl();

  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;
  final _cache = CacheService();

  @override
  Future<Either<Failure, GetFromCart>> getFromCart() async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final cacheKey = 'cart_$_userId';
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        return right(GetFromCart.fromJson(cached));
      }
      final data = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', _userId!);
      final cartId = data.isNotEmpty
          ? (data.first['cart_id'] as int?) ?? (data.first['id'] as int?)
          : 0;
      double total = 0;
      for (final item in data) {
        final price = (item['products'] is Map
                ? (item['products']['price'] as num?)?.toDouble()
                : null) ??
            0;
        final qty = (item['quantity'] as int?) ?? 1;
        total += price * qty;
      }
      final json = {
        'cart': {
          'id': cartId,
          'user_id': _userId,
          'status': 1,
          'is_open': 1,
          'totalPrice': total,
        },
        'details': data,
      };
      await _cache.put(cacheKey, json);
      GetFromCart getFromCart = GetFromCart.fromJson(json);
      return right(getFromCart);
    } catch (e) {
      final cacheKey = 'cart_$_userId';
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        return right(GetFromCart.fromJson(cached));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addToCart({required int id, int quantity = 1}) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final existing = await _supabase
          .from('cart_items')
          .select('id, quantity, cart_id')
          .eq('user_id', _userId!)
          .eq('product_id', id)
          .maybeSingle();
      if (existing != null) {
        await _supabase
            .from('cart_items')
            .update({'quantity': (existing['quantity'] as int? ?? 0) + quantity})
            .eq('id', existing['id']);
      } else {
        int? cartId;
        final anyItem = await _supabase
            .from('cart_items')
            .select('cart_id')
            .eq('user_id', _userId!)
            .limit(1)
            .maybeSingle();
        if (anyItem != null) {
          cartId = anyItem['cart_id'] as int?;
        }
        cartId ??= DateTime.now().millisecondsSinceEpoch;
        await _supabase.from('cart_items').insert({
          'user_id': _userId!,
          'product_id': id,
          'quantity': quantity,
          'cart_id': cartId,
        });
      }
      await _cache.remove('cart_$_userId');
      return right('Added to cart successfully');
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deletefromCart({
    required int cart_id,
    required int product_id,
  }) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final deleted = await _supabase
          .from('cart_items')
          .delete()
          .eq('id', cart_id)
          .eq('product_id', product_id)
          .eq('user_id', _userId!)
          .select();
      if (deleted.isEmpty) {
        return left(ServerFailure('Item not found or already removed'));
      }
      await _cache.remove('cart_$_userId');
      return right('Removed from cart');
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConfirmCart>> confirmCart({
    required int id,
    required String userId,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? addressLabel,
  }) async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null || uid.isEmpty) {
        return left(ServerFailure('Please sign in to checkout'));
      }
      final items = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', uid);
      double total = 0;
      int? cartId;
      for (final item in items) {
        final price = (item['products'] is Map
                ? (item['products']['price'] as num?)?.toDouble()
                : null) ??
            0;
        final qty = (item['quantity'] as int?) ?? 1;
        total += price * qty;
        cartId ??= (item['cart_id'] as int?) ?? (item['id'] as int?);
      }
      final insertPayload = {
        'user_id': uid,
        'cart_id': cartId ?? id,
        'total_price': total,
        'status': 'pending',
      };
      if (deliveryAddress != null && deliveryAddress.isNotEmpty) {
        insertPayload['delivery_address'] = deliveryAddress;
      }
      if (deliveryLat != null && deliveryLng != null) {
        insertPayload['delivery_lat'] = deliveryLat;
        insertPayload['delivery_lng'] = deliveryLng;
      }
      if (addressLabel != null && addressLabel.isNotEmpty) {
        insertPayload['address_label'] = addressLabel;
      }
      final order = await _supabase.from('orders').insert(insertPayload).select().single();
      final orderId = order['id'] as int;
      for (final item in items) {
        await _supabase.from('order_items').insert({
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
        });
      }
      await _supabase.from('cart_items').delete().eq('user_id', uid);
      await _cache.remove('cart_$uid');
      ConfirmCart confirmCart = ConfirmCart.fromJson({
        'success': 'Order confirmed',
        'order': order,
      });
      return right(confirmCart);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> checkOut({required int totalPrice, int? orderId}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(ServerFailure('Not authenticated'));
      if (orderId == null) return left(ServerFailure('Missing order ID'));

      final result = await _supabase.functions.invoke(
        'paymob-checkout',
        body: {
          'totalPrice': totalPrice,
          'orderId': orderId,
          'userId': userId,
        },
      );

      final data = (result as FunctionResponse).data as Map<String, dynamic>;
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        return left(ServerFailure('Failed to get payment URL'));
      }

      return right(Payment(url: url, message: data['transactionId']?.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrderHistory() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null || uid.isEmpty) {
        return left(ServerFailure('Not authenticated'));
      }
      final data = await _supabase
          .from('orders')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(50);
      return right(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSuggestedProducts(List<String> categories, {List<int> excludeIds = const []}) async {
    try {
      if (categories.isEmpty) return right([]);
      var data = await _supabase
          .from('products')
          .select()
          .inFilter('category', categories)
          .limit(20);
      final list = List<Map<String, dynamic>>.from(data);
      if (excludeIds.isNotEmpty) {
        list.removeWhere((p) => excludeIds.contains(p['id'] as int?));
      }
      return right(list.take(10).toList());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
