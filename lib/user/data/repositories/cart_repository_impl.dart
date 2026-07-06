import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/user/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/user/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/user/data/models/payment/payment.dart';
import 'package:ship_link/user/domain/repositories/cart_repository.dart';
import 'package:ship_link/user/data/datasources/cart_remote_datasource.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepositoryImpl extends CartRepository {
  CartRepositoryImpl();

  final _dataSource = CartRemoteDataSource();
  final _cache = CacheService();
  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<Either<Failure, GetFromCart>> getFromCart() async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final cacheKey = 'cart_$_userId';
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        return right(GetFromCart.fromJson(cached));
      }
      final data = await _dataSource.getCartItems();
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
      final existing = await _dataSource.getExistingCartItem(id);
      if (existing != null) {
        await _dataSource.updateCartItemQuantity(existing['id'], (existing['quantity'] as int? ?? 0) + quantity);
      } else {
        int? cartId;
        final anyItem = await _dataSource.getAnyCartItem();
        if (anyItem != null) cartId = anyItem['cart_id'] as int?;
        cartId ??= DateTime.now().millisecondsSinceEpoch;
        await _dataSource.insertCartItem({
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
  Future<Either<Failure, String>> deletefromCart({required int cart_id, required int product_id}) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final deleted = await _dataSource.deleteCartItem(cart_id, product_id);
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
    String? phoneNumber,
    String? deliveryInstructions,
    String paymentMethod = 'cod',
  }) async {
    try {
      final uid = _userId;
      if (uid == null || uid.isEmpty) {
        return left(ServerFailure('Please sign in to checkout'));
      }
      final items = await _dataSource.getCartItems();
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
      final initialStatus = paymentMethod == 'card' ? 'awaiting_payment' : 'pending';
      final insertPayload = <String, dynamic>{
        'user_id': uid,
        'cart_id': cartId ?? id,
        'total_price': total,
        'status': initialStatus,
        'payment_method': paymentMethod,
      };
      if (deliveryAddress != null && deliveryAddress.isNotEmpty) insertPayload['delivery_address'] = deliveryAddress;
      if (deliveryLat != null && deliveryLng != null) {
        insertPayload['delivery_lat'] = deliveryLat;
        insertPayload['delivery_lng'] = deliveryLng;
      }
      if (addressLabel != null && addressLabel.isNotEmpty) insertPayload['address_label'] = addressLabel;
      if (phoneNumber != null && phoneNumber.isNotEmpty) insertPayload['phone_number'] = phoneNumber;
      if (deliveryInstructions != null && deliveryInstructions.isNotEmpty) insertPayload['delivery_instructions'] = deliveryInstructions;

      final profile = await _dataSource.getProfileName();
      if (profile != null && profile['name'] != null) insertPayload['customer_name'] = profile['name'];

      final order = await _dataSource.createOrder(insertPayload);
      if (order == null) return left(ServerFailure('Failed to create order'));
      final orderId = order['id'] as int;
      for (final item in items) {
        await _dataSource.insertOrderItem({
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
        });
      }
      ConfirmCart confirmCart = ConfirmCart.fromJson({'success': 'Order confirmed', 'order': order});
      return right(confirmCart);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> checkOut({required int totalPrice, int? orderId, String? redirectUri}) async {
    try {
      final userId = _userId;
      if (userId == null) return left(ServerFailure('Not authenticated'));
      if (orderId == null) return left(ServerFailure('Missing order ID'));
      final body = <String, dynamic>{'totalPrice': totalPrice, 'orderId': orderId, 'userId': userId};
      if (redirectUri != null) body['redirectUri'] = redirectUri;
      final data = await _dataSource.invokePaymobCheckout(body);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) return left(ServerFailure('Failed to get payment URL'));
      return right(Payment(url: url, message: data['transactionId']?.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrderHistory() async {
    try {
      final data = await _dataSource.getOrderHistory();
      return right(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSuggestedProducts(List<String> categories, {List<int> excludeIds = const []}) async {
    try {
      if (categories.isEmpty) return right([]);
      var data = await _dataSource.getSuggestedProducts(categories);
      final list = List<Map<String, dynamic>>.from(data);
      if (excludeIds.isNotEmpty) list.removeWhere((p) => excludeIds.contains(p['id'] as int?));
      return right(list.take(10).toList());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
