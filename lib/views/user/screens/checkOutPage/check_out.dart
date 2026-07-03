import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/cubits/payment/payment_cubit.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/user/screens/congrats/congrates.dart';
import 'package:ship_link/views/user/screens/paymentWebView/payment_web_view.dart';
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

class _CheckOutPageState extends State<CheckOutPage>
    with SingleTickerProviderStateMixin {
  int _selectedMethod = 0;
  bool _processing = false;
  bool _loadingAddresses = true;
  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;
  final _phoneCtrl = TextEditingController();
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
        setState(() {
          _addresses = addrs;
          _selectedAddressId = defaultAddr?['id'] as String?;
          _phoneCtrl.text = profile?['phone_number'] as String? ?? '';
          _loadingAddresses = false;
        });
        _animCtrl.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  Map<String, dynamic>? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    try {
      return _addresses.firstWhere((a) => a['id'] == _selectedAddressId);
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
    _phoneCtrl.dispose();
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
            setState(() => _processing = false);
            CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
          }
        },
        builder: (context, state) {
          final isOrdering = state is ConfirmCartLoading;
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
                      onPressed: (_processing || isOrdering || _selectedAddress == null || _phoneCtrl.text.trim().isEmpty)
                          ? null
                          : () => _placeOrder(context),
                      child: (_processing || isOrdering)
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
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.t.tr('delivery_details'),
                style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/addressBook'),
              icon: Icon(Icons.add, size: 18),
              label: Text(context.t.tr('add_address')),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (_loadingAddresses)
          Container(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_addresses.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.location_off_outlined, size: 48, color: AppColors.textDisabled),
                SizedBox(height: 12.h),
                Text(context.t.tr('no_addresses'),
                    style: appStyle(15, FontWeight.w500, AppColors.textSecondary)),
              ],
            ),
          )
        else
          ...List.generate(_addresses.length, (i) {
            final addr = _addresses[i];
            final isSelected = addr['id'] == _selectedAddressId;
            final label = addr['label'] as String? ?? '';
            final city = addr['city'] as String? ?? '';
            final street = addr['street'] as String? ?? '';
            final full = addr['full_address'] as String? ?? '';
            final isDefault = addr['is_default'] == true;
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: GestureDetector(
                onTap: () => setState(() => _selectedAddressId = addr['id'] as String?),
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
                        size: 22,
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
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.cta.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
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
      ],
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    setState(() => _processing = true);
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
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
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
              size: 22,
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

      final paymentMethod = _selectedMethod == 0 ? 'cod' : 'card';
      await supabase.from('orders').update({'payment_method': paymentMethod}).eq('id', orderId);

      if (_selectedMethod == 0) {
        if (uid != null) {
          await supabase.from('cart_items').delete().eq('user_id', uid);
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
        final paymentCubit = context.read<PaymentCubit>();
        await paymentCubit.checkout(
          totalPrice: _finalTotal.round(),
          orderId: orderId,
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
      if (mounted) setState(() => _processing = false);
    }
  }
}
