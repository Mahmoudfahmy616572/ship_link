import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/services/supabase_service.dart';
import 'package:ship_link/views/user/screens/cart/components/checkout_button.dart';

class ButtomNavBar extends StatefulWidget {
  ButtomNavBar({super.key});

  @override
  State<ButtomNavBar> createState() => _ButtomNavBarState();
}

class _ButtomNavBarState extends State<ButtomNavBar> {
  final _promoCtrl = TextEditingController();
  int _discountPercent = 0;
  String? _promoMsg;
  bool _checking = false;

  Future<void> _applyCode() async {
    final code = _promoCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _checking = true);
    final pct = await SupabaseService().verifyPromoCode(code);
    setState(() {
      _checking = false;
      _discountPercent = pct ?? 0;
      _promoMsg = pct != null ? context.t.tr('percent_off_applied') : context.t.tr('invalid_promo_code');
    });
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetFromCartCubit, GetFromCartState>(
      builder: (context, state) {
        if (state is! GetFromCartSuccess) return const SizedBox.shrink();
        final details = state.getProductFromCart.details ?? [];
        final total = details.fold<double>(
          0.0,
          (sum, d) => sum + (d.product?.price ?? 0.0) * (d.qty ?? 1),
        );
        final discount = total * _discountPercent / 100;
        final finalTotal = total - discount;

        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Promo Code ──
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: TextField(
                        controller: _promoCtrl,
                        style: appStyle(14, FontWeight.normal, AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: context.t.tr('promo_code'),
                          hintStyle: appStyle(14, FontWeight.normal, AppColors.textHint),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 44.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: _checking ? null : _applyCode,
                      child: _checking
                          ? SizedBox(
                              width: 20.w, height: 20.h,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(context.t.tr('apply')),
                    ),
                  ),
                ],
              ),
              if (_promoMsg != null)
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        _discountPercent > 0 ? Icons.check_circle : Icons.error,
                        size: 16.sp,
                        color: _discountPercent > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _promoMsg!,
                        style: appStyle(
                          13,
                          FontWeight.w500,
                          _discountPercent > 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 12.h),
              // ── Summary ──
              if (_discountPercent > 0) ...[
                  _SummaryRow(
                  context.t.tr('original_price'),
                  '\$${total.toStringAsFixed(2)}',
                  AppColors.textHint,
                  strikeThrough: true,
                ),
                SizedBox(height: 4.h),
                _SummaryRow(
                    '${context.t.tr('discount')} ($_discountPercent%)', '-\$${discount.toStringAsFixed(2)}', AppColors.success),
                SizedBox(height: 4.h),
              ],
              _SummaryRow(
                context.t.tr('total'),
                '\$${finalTotal.toStringAsFixed(2)}',
                AppColors.cta,
                bold: true,
                large: true,
              ),
              SizedBox(height: 14.h),
              CheckoutButton(
                text: context.t.tr('proceed_to_checkout'),
                id: state.getProductFromCart.cart?.id ?? 0,
                userId: state.getProductFromCart.cart?.userId ?? '',
                discountPercent: _discountPercent,
                cartData: state.getProductFromCart,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool strikeThrough;
  final bool bold;
  final bool large;

  const _SummaryRow(
    this.label,
    this.value,
    this.color, {
    this.strikeThrough = false,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: appStyle(
            large ? 17 : 15,
            bold ? FontWeight.w700 : FontWeight.w500,
            color,
          ),
        ),
        Text(
          value,
          style: appStyle(
            large ? 20 : 15,
            bold ? FontWeight.w700 : FontWeight.w600,
            color,
          ).copyWith(
            decoration: strikeThrough ? TextDecoration.lineThrough : null,
            decorationColor: color,
          ),
        ),
      ],
    );
  }
}
