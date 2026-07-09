import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final _supabase = Supabase.instance.client;
  final int orderId;

  OrderDetailCubit({required this.orderId}) : super(const OrderDetailInitial());

  Future<void> load() async {
    emit(const OrderDetailLoading());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) { emit(const OrderDetailError('Not authenticated')); return; }

      final order = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (order == null) { emit(const OrderDetailError('Order not found')); return; }

      final rawItems = await _supabase
          .from('order_items')
          .select('product_id, quantity')
          .eq('order_id', orderId);

      final items = <Map<String, dynamic>>[];
      for (final item in rawItems) {
        final pid = item['product_id'] as int?;
        if (pid == null) continue;
        final product = await _supabase
            .from('products')
            .select()
            .eq('id', pid)
            .maybeSingle();
        items.add({
          'quantity': item['quantity'],
          'product_id': pid,
          'products': product,
        });
      }

      if (!isClosed) emit(OrderDetailLoaded(order: order, items: items));
    } catch (e) {
      if (!isClosed) emit(OrderDetailError(e.toString()));
    }
  }

  Future<void> cancelOrder() async {
    try {
      await _supabase.from('orders').update({'status': 'cancelled'}).eq('id', orderId);
      await load();
    } catch (e) {
      if (!isClosed) emit(OrderDetailError(e.toString()));
    }
  }

  Future<void> submitRating(int rating) async {
    try {
      final current = state;
      if (current is! OrderDetailLoaded) return;
      await _supabase.from('driver_ratings').insert({
        'user_id': _supabase.auth.currentUser?.id,
        'driver_id': current.order['driver_id'],
        'order_id': orderId,
        'rating': rating,
      });
    } catch (e) {
      if (!isClosed) emit(OrderDetailError(e.toString()));
    }
  }
}
