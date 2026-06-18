import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/data/models/payment/payment.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartServeicesImpl extends CartServeices {
  CartServeicesImpl();

  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  Future<Either<Failure, GetFromCart>> getFromCart() async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final data = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', _userId!);
      GetFromCart getFromCart = GetFromCart.fromJson({
        'cart': {'id': 0, 'user_id': _userId, 'status': 1, 'is_open': 1},
        'details': data,
      });
      return right(getFromCart);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future addToCart({required int id}) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      await _supabase.from('cart_items').upsert({
        'user_id': _userId!,
        'product_id': id,
        'quantity': 1,
      });
      return right(true);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future deletefromCart({
    required int cart_id,
    required int product_id,
  }) async {
    try {
      await _supabase
          .from('cart_items')
          .delete()
          .eq('id', cart_id)
          .eq('product_id', product_id);
      return right(true);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConfirmCart>> confirmCart(
      {required int id, required int userId}) async {
    try {
      final data = await _supabase.from('orders').insert({
        'user_id': userId,
        'cart_id': id,
        'status': 'pending',
      }).select();
      ConfirmCart confirmCart = ConfirmCart.fromJson({
        'success': 'Order confirmed',
        'order': data.isNotEmpty ? data.first : null,
      });
      return right(confirmCart);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> checkOut({required int totalPrice}) async {
    try {
      Payment payment = Payment(
        url: 'https://shiplink.spider-te8.com/checkout?total=$totalPrice',
      );
      return right(payment);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
