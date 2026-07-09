import 'dart:html' as html;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final _supabase = Supabase.instance.client;

  CheckoutCubit() : super(const CheckoutInitial());

  double get total {
    final current = state;
    if (current is! CheckoutLoaded) return 0;
    double t = 0;
    for (final item in current.items) {
      final product = item['products'] as Map<String, dynamic>?;
      final price = (product?['price'] as num? ?? 0).toDouble();
      final qty = (item['quantity'] as int? ?? 1);
      t += price * qty;
    }
    return t;
  }

  Future<void> load() async {
    emit(const CheckoutLoading());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) { emit(const CheckoutError('Not authenticated')); return; }

      final itemsFuture = _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id);

      final addressesFuture = _supabase
          .from('user_addresses')
          .select('*')
          .eq('user_id', user.id)
          .order('is_default', ascending: false);

      final profileFuture = _supabase
          .from('profiles')
          .select('phone_number')
          .eq('id', user.id)
          .maybeSingle();

      final results = await Future.wait([itemsFuture, addressesFuture, profileFuture]);
      final items = List<Map<String, dynamic>>.from(results[0] as List);
      final addresses = List<Map<String, dynamic>>.from(results[1] as List);
      final profile = results[2] as Map<String, dynamic>?;

      final phone = profile?['phone_number'] as String? ?? '';

      final defaultAddr = addresses.cast<Map<String, dynamic>?>().firstWhere(
        (a) => a?['is_default'] == true,
        orElse: () => addresses.isNotEmpty ? addresses.first : null,
      );

      if (!isClosed) emit(CheckoutLoaded(
        items: items,
        addresses: addresses,
        selectedAddressId: defaultAddr?['id'] as String?,
        phone: phone,
        paymentMethod: 0,
      ));
    } catch (e) {
      if (!isClosed) emit(CheckoutError(e.toString()));
    }
  }

  void selectAddress(String? id) {
    final current = state;
    if (current is! CheckoutLoaded) return;
    if (!isClosed) emit(CheckoutLoaded(
      items: current.items,
      addresses: current.addresses,
      selectedAddressId: id,
      phone: current.phone,
      paymentMethod: current.paymentMethod,
    ));
  }

  void selectPaymentMethod(int method) {
    final current = state;
    if (current is! CheckoutLoaded) return;
    if (!isClosed) emit(CheckoutLoaded(
      items: current.items,
      addresses: current.addresses,
      selectedAddressId: current.selectedAddressId,
      phone: current.phone,
      paymentMethod: method,
    ));
  }

  Map<String, dynamic>? get _selectedAddress {
    final current = state;
    if (current is! CheckoutLoaded || current.selectedAddressId == null) return null;
    try {
      return current.addresses.firstWhere((a) => a['id'] == current.selectedAddressId);
    } catch (_) {
      return null;
    }
  }

  Future<String?> placeOrder({required String phone}) async {
    emit(const CheckoutPlacing());
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      final current = state;
      if (user == null || current is! CheckoutLoaded) return 'Not authenticated';

      final userEmail = user.email ?? '';
      final addr = _selectedAddress;

      final profile = await supabase
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      final totalPrice = total;
      final isCard = current.paymentMethod == 1;

      final order = await supabase.from('orders').insert({
        'user_id': user.id,
        'total_price': totalPrice,
        'status': isCard ? 'awaiting_payment' : 'pending',
        'payment_method': isCard ? 'card' : 'cod',
        'delivery_address': addr?['full_address'] as String? ?? '',
        'phone_number': phone,
        'customer_name': profile?['name'],
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      for (final item in current.items) {
        await supabase.from('order_items').insert({
          'order_id': order['id'],
          'product_id': item['product_id'],
          'quantity': item['quantity'],
        });
      }

      await supabase.from('cart_items').delete().eq('user_id', user.id);

      if (isCard) {
        try {
          var origin = Uri.base.origin;
          if (origin.startsWith('http://')) {
            origin = origin.replaceFirst('http://', 'https://');
          }
          final result = await supabase.functions.invoke('paymob-checkout', body: {
            'totalPrice': totalPrice.round(),
            'orderId': order['id'],
            'userId': user.id,
            'redirectUri': '$origin/orders',
          }) as Map<String, dynamic>;
          final url = result['url'] as String?;
          if (url != null && url.isNotEmpty) {
            html.window.open(url.replaceFirst('http://', 'https://'), '_blank');
          }
        } catch (e) {
          print('Paymob checkout error: $e');
        }

        if (!isClosed) emit(CheckoutPaymentOpened(userEmail: userEmail));
      } else {
        if (!isClosed) emit(CheckoutSuccess(userEmail: userEmail));
      }
      return null;
    } catch (e) {
      if (!isClosed) emit(CheckoutError(e.toString()));
      return e.toString();
    }
  }
}
