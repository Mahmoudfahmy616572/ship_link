import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/user/presentation/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/payment/payment_cubit.dart';
import 'package:ship_link/user/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/user/presentation/screens/checkOutPage/check_out.dart';

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
        onPressed: () {
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
                  cartData: cartData,
                ),
              ),
            ),
          );
        },
        child: Text(text),
      ),
    );
  }
}
