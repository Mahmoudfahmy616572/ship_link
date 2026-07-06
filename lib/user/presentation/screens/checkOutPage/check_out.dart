import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/user/presentation/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/payment/payment_cubit.dart';
import 'package:ship_link/user/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/screens/congrats/congrates.dart';
import 'package:ship_link/user/presentation/screens/paymentWebView/payment_web_view.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({
    super.key,
    this.discountPercent = 0,
    this.originalTotal = 0,
    this.cartData,
  });

  static String routName = '/checkOutPage';
  final int discountPercent;
  final int originalTotal;
  final GetFromCart? cartData;

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckoutState {
  final List<Map<String, dynamic>> addresses;
  final String? selectedAddressId;
  final bool loadingAddresses;
  final bool processing;
  final int selectedMethod;

  const _CheckoutState({
    this.addresses = const [],
    this.selectedAddressId,
    this.loadingAddresses = true,
    this.processing = false,
    this.selectedMethod = 0,
  });

  _CheckoutState copyWith({
    List<Map<String, dynamic>>? addresses,
    Object? selectedAddressId = _sentinel,
    bool? loadingAddresses,
    bool? processing,
    int? selectedMethod,
  }) {
    return _CheckoutState(
      addresses: addresses ?? this.addresses,
      selectedAddressId: identical(selectedAddressId, _sentinel)
          ? this.selectedAddressId
          : selectedAddressId as String?,
      loadingAddresses: loadingAddresses ?? this.loadingAddresses,
      processing: processing ?? this.processing,
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }

  static const _sentinel = Object();
}

class _CheckOutPageState extends State<CheckOutPage>
    with SingleTickerProviderStateMixin {
  final _state = ValueNotifier<_CheckoutState>(_CheckoutState());
  final _phoneCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final addrFuture = Supabase.instance.client
          .from('user_addresses')
          .select('*')
          .eq('user_id', user.id)
          .order('is_default', ascending: false);
      final profileFuture = Supabase.instance.client
          .from('profiles')
          .select('phone_number')
          .eq('id', user.id)
          .maybeSingle();
      final results = await Future.wait([addrFuture, profileFuture]);
      final addrs = List<Map<String, dynamic>>.from(results[0] as List);
      final profile = results[1] as Map<String, dynamic>?;
      final defaultAddr = addrs.cast<Map<String, dynamic>?>().firstWhere(
        (a) => a?['is_default'] == true,
        orElse: () => addrs.isNotEmpty ? addrs.first : null,
      );
      if (mounted) {
        _state.value = _state.value.copyWith(
          addresses: addrs,
          selectedAddressId: defaultAddr?['id'] as String?,
          loadingAddresses: false,
        );
        _phoneCtrl.text = profile?['phone_number'] as String? ?? '';
        _animCtrl.forward();
      }
    } catch (_) {
      if (mounted) {
        _state.value = _state.value.copyWith(loadingAddresses: false);
      }
    }
  }

  Map<String, dynamic>? get _selectedAddress {
    final s = _state.value;
    if (s.selectedAddressId == null) return null;
    try {
      return s.addresses.firstWhere((a) => a['id'] == s.selectedAddressId);
    } catch (_) {
      return null;
    }
  }

  double get _subtotal {
    final details = widget.cartData?.details ?? [];
    return details.fold<double>(
      0.0,
      (sum, d) => sum + (d.product?.price ?? 0.0) * (d.qty ?? 1),
    );
  }

  double get _discountAmount => _subtotal * widget.discountPercent / 100;
  double get _finalTotal => _subtotal - _discountAmount;

  @override
  void dispose() {
    _state.dispose();
    _phoneCtrl.dispose();
    _instructionsCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('checkout')),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: BlocConsumer<ConfirmCartCubit, ConfirmCartState>(
        listenWhen: (_, current) =>
            current is ConfirmCartSuccess || current is ConfirmCartFailure,
        listener: (context, state) {
          if (state is ConfirmCartSuccess) {
            _processPayment(context, state.confirmCart.order?.id);
          } else if (state is ConfirmCartFailure) {
            _state.value = _state.value.copyWith(processing: false);
            CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
          }
        },
        builder: (context, state) {
          final isOrdering = state is ConfirmCartLoading;
          return ValueListenableBuilder<_CheckoutState>(
            valueListenable: _state,
            builder: (context, s, _) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeliverySection(),
                      SizedBox(height: 24.h),
                      _buildOrderSummary(),
                      SizedBox(height: 24.h),
                      Text("Payment Method",
                          style: appStyle(18, FontWeight.w600, AppColors.textPrimary)),
                      SizedBox(height: 12.h),
                      _paymentCard(0, Icons.money_rounded, "Cash on Delivery",
                          "Pay when you receive your order"),
                      SizedBox(height: 10.h),
                      _paymentCard(1, Icons.credit_card_rounded, "Pay with Paymob",
                          "Pay online via credit/debit card"),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.cta,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          onPressed: (s.processing || isOrdering || _selectedAddress == null || _phoneCtrl.text.trim().isEmpty)
                              ? null
                              : () => _placeOrder(context),
                          child: (s.processing || isOrdering)
                              ? SizedBox(
                                  width: 22.w, height: 22.h,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text("Place Order",
                                  style: appStyle(16, FontWeight.w600, Colors.white)),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDeliverySection() {
    final s = _state.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(context.t.tr('delivery_details'),
                  style: appStyle(16, FontWeight.w700, AppColors.textPrimary)),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/addressBook'),
              icon: Icon(Icons.add, size: 16.sp),
              label: Text(context.t.tr('add_address'), style: TextStyle(fontSize: 13.sp)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (s.loadingAddresses)
          Container(
            padding: EdgeInsets.all(24.w),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (s.addresses.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.location_off_outlined, size: 48.sp, color: AppColors.textDisabled),
                SizedBox(height: 12.h),
                Text(context.t.tr('no_addresses'),
                    style: appStyle(15, FontWeight.w500, AppColors.textSecondary)),
              ],
            ),
          )
        else
          ...List.generate(s.addresses.length, (i) {
            final addr = s.addresses[i];
            final isSelected = addr['id'] == s.selectedAddressId;
            final label = addr['label'] as String? ?? '';
            final city = addr['city'] as String? ?? '';
            final street = addr['street'] as String? ?? '';
            final full = addr['full_address'] as String? ?? '';
            final isDefault = addr['is_default'] == true;
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: GestureDetector(
                onTap: () => _state.value = _state.value.copyWith(
                  selectedAddressId: addr['id'] as String?,
                ),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : AppColors.textDisabled,
                        size: 22.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(label,
                                    style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
                                if (isDefault) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.cta.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(context.t.tr('default'),
                                        style: appStyle(11, FontWeight.w600, AppColors.cta)),
                                  ),
                                ],
                              ],
                            ),
                            if (city.isNotEmpty || street.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text([street, city].where((s) => s.isNotEmpty).join(', '),
                                  style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
                            ],
                            if (full.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(full,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: appStyle(12, FontWeight.w400, const Color(0xFF9CA3AF))),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: context.t.tr('phone_number'),
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: TextField(
            controller: _instructionsCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: context.t.tr('delivery_instructions'),
              hintText: context.t.tr('delivery_instructions_hint'),
              prefixIcon: Icon(Icons.notes_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    _state.value = _state.value.copyWith(processing: true);
    final addr = _selectedAddress;
    if (addr == null) return;
    final lat = (addr['latitude'] as num?)?.toDouble();
    final lng = (addr['longitude'] as num?)?.toDouble();
    final addrText = addr['full_address'] as String? ?? '';
    final label = addr['label'] as String? ?? '';
    context.read<ConfirmCartCubit>().confirmCart(
      id: widget.cartData?.cart?.id ?? 0,
      userId: Supabase.instance.client.auth.currentUser?.id,
      deliveryAddress: addrText.isNotEmpty ? addrText : null,
      deliveryLat: lat,
      deliveryLng: lng,
      addressLabel: label,
      phoneNumber: _phoneCtrl.text.trim(),
      deliveryInstructions: _instructionsCtrl.text.trim(),
      paymentMethod: _state.value.selectedMethod == 0 ? 'cod' : 'card',
    );
  }

  Widget _buildOrderSummary() {
    final details = widget.cartData?.details ?? [];
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w, height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.receipt_long, color: AppColors.primary, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text("Order Summary",
                  style: appStyle(16, FontWeight.w600, AppColors.textPrimary)),
            ],
          ),
          Divider(height: 24.h),
          if (details.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text("No items",
                  style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
            )
          else
            ...details.map((d) => _itemRow(d)),
          Divider(height: 16.h),
          _row("Subtotal", "\$${_subtotal.toStringAsFixed(2)}"),
          if (widget.discountPercent > 0)
            _row("Discount (${widget.discountPercent}%)",
                "-\$${_discountAmount.toStringAsFixed(2)}"),
          Divider(height: 16.h),
          _row("Total", "\$${_finalTotal.toStringAsFixed(2)}", bold: true),
        ],
      ),
    );
  }

  Widget _itemRow(Detail d) {
    final name = d.product?.name ?? "Item";
    final qty = d.qty ?? 1;
    final price = d.product?.price ?? 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: appStyle(14, FontWeight.w500, AppColors.textPrimary)),
          ),
          Text("x$qty",
              style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
          SizedBox(width: 16.w),
          SizedBox(
            width: 70.w,
            child: Text("\$${(price * qty).toStringAsFixed(2)}",
                textAlign: TextAlign.right,
                style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: appStyle(bold ? 15 : 14,
                  bold ? FontWeight.w600 : FontWeight.w400,
                  bold ? AppColors.textPrimary : AppColors.textSecondary)),
          Text(value,
              style: appStyle(bold ? 15 : 14,
                  bold ? FontWeight.w700 : FontWeight.w500,
                  AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _paymentCard(int index, IconData icon, String title, String subtitle) {
    final isSelected = _state.value.selectedMethod == index;
    return GestureDetector(
      onTap: () => _state.value = _state.value.copyWith(selectedMethod: index),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w, height: 48.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon,
                  color: isSelected ? AppColors.primary : AppColors.textDisabled),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.border,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, int? orderId) async {
    if (orderId == null) return;
    try {
      final supabase = Supabase.instance.client;
      final uid = supabase.auth.currentUser?.id;
      final userEmail = supabase.auth.currentUser?.email ?? "your email";

      final paymentMethod = _state.value.selectedMethod == 0 ? 'cod' : 'card';
      await supabase.from('orders').update({'payment_method': paymentMethod}).eq('id', orderId);

      if (_state.value.selectedMethod == 0) {
        if (uid != null) {
          await supabase.from('cart_items').delete().eq('user_id', uid);
          await CacheService().remove('cart_$uid');
        }
        if (!mounted) return;
        CustomSnackBar.displaySuccessMotionToast(
            "Order placed successfully!", context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<ConfirmCartCubit>()),
                BlocProvider.value(value: context.read<PaymentCubit>()),
              ],
              child: Congrates(userEmail: userEmail),
            ),
          ),
        );
      } else {
        // Check for saved payment methods
        final savedCards = uid != null
            ? await supabase
                .from('payment_methods')
                .select()
                .eq('user_id', uid)
                .order('is_default', ascending: false)
                .limit(20)
            : [];
        final savedList = List<Map<String, dynamic>>.from(savedCards);
        String? selectedToken;
        if (savedList.isNotEmpty && mounted) {
          selectedToken = await showDialog<String>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: const Text('Pay with'),
              children: [
                ...savedList.map((card) {
                  final token = card['paymob_token'] as String;
                  final lastFour = card['last_four'] as String? ?? '****';
                  final brand = card['card_brand'] as String? ?? '';
                  final isDefault = card['is_default'] == true;
                  return SimpleDialogOption(
                    onPressed: () => Navigator.of(ctx).pop(token),
                    child: Row(
                      children: [
                        Icon(Icons.credit_card, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text('$brand •••• $lastFour${isDefault ? ' (Default)' : ''}'),
                      ],
                    ),
                  );
                }),
                SimpleDialogOption(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text('Pay with new card'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        if (selectedToken != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter your card details to complete payment')),
          );
        }
        // Pay with card (saved cards redirect to regular checkout for now)
        final paymentCubit = context.read<PaymentCubit>();
        const appScheme = 'com.example.ship_link.user';
        await paymentCubit.checkout(
          totalPrice: _finalTotal.round(),
          orderId: orderId,
          redirectUri: '$appScheme://callback',
        );
        if (!mounted) return;
        final paymentState = paymentCubit.state;
        if (paymentState is PaymentSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<ConfirmCartCubit>()),
                  BlocProvider.value(value: context.read<PaymentCubit>()),
                ],
                child: WebPage(url: paymentState.payment.url ?? "", orderId: orderId),
              ),
            ),
          );
        } else if (paymentState is PaymentFailure) {
          debugPrint('Payment error from Paymob: ${paymentState.errMessage}');
          CustomSnackBar.displayErrorMotionToast(
              paymentState.errMessage, context);
        }
      }
    } catch (e) {
      debugPrint('Payment exception: $e');
      if (mounted) {
        CustomSnackBar.displayErrorMotionToast(e.toString(), context);
      }
    } finally {
      if (mounted) _state.value = _state.value.copyWith(processing: false);
    }
  }
}
