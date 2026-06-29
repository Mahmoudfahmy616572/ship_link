import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/cubits/payment/payment_cubit.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/user/screens/checkOutPage/check_out.dart';
import 'package:ship_link/views/user/screens/address_book/address_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({
    super.key,
    required this.text,
    this.id,
    this.userId,
    this.discountPercent = 0,
    this.cartData,
  });

  final String text;
  final int? id;
  final String? userId;
  final int discountPercent;
  final GetFromCart? cartData;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfirmCartCubit, ConfirmCartState>(
      listener: (context, state) {
        if (state is ConfirmCartLoading) {
        } else if (state is ConfirmCartFailure) {
          CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
        } else if (state is ConfirmCartSuccess) {
          final original = state.confirmCart.order?.totalPrice ?? 0;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<ConfirmCartCubit>()),
                  BlocProvider.value(value: context.read<PaymentCubit>()),
                ],
                child: CheckOutPage(
                  discountPercent: discountPercent,
                  originalTotal: original,
                  cartData: cartData,
                ),
              ),
            ),
          );
          CustomSnackBar.displaySuccessMotionToast(
              state.confirmCart.success ?? '', context);
        }
      },
      builder: (context, state) {
        final loading = state is ConfirmCartLoading;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: appStyle(16, FontWeight.w600, Colors.white),
            ),
            onPressed: loading
                ? null
                : () => _pickAddressAndCheckout(context),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(text),
          ),
        );
      },
    );
  }

  Future<void> _pickAddressAndCheckout(BuildContext context) async {
    final addresses = await Supabase.instance.client
        .from('user_addresses')
        .select()
        .eq('user_id', Supabase.instance.client.auth.currentUser?.id ?? '')
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    if (!context.mounted) return;

    if (addresses.isEmpty) {
      CustomSnackBar.displayErrorMotionToast(
          'Please add a delivery address first in Address Book', context);
      return;
    }

    // Auto-use default address if one exists
    final defaultAddr = addresses.firstWhere(
      (a) => a['is_default'] == true,
      orElse: () => <String, dynamic>{},
    );
    if (defaultAddr.isNotEmpty) {
      _checkoutWithAddress(context, defaultAddr);
      return;
    }

    // No default set — force user to pick one
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddressPicker(addresses: List<Map<String, dynamic>>.from(addresses)),
    );

    if (!context.mounted || selected == null) return;
    _checkoutWithAddress(context, selected);
  }

  void _checkoutWithAddress(BuildContext context, Map<String, dynamic> addr) {
    final lat = (addr['latitude'] as num?)?.toDouble();
    final lng = (addr['longitude'] as num?)?.toDouble();
    final addrText = addr['full_address'] as String? ?? '';
    final label = addr['label'] as String? ?? '';

    if (!context.mounted) return;
    context
        .read<ConfirmCartCubit>()
        .confirmCart(
          id: id,
          userId: userId,
          deliveryAddress: addrText.isNotEmpty ? addrText : null,
          deliveryLat: lat,
          deliveryLng: lng,
          addressLabel: label,
        );
  }
}
