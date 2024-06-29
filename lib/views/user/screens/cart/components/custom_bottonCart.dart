// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';

import '../../../../../cubits/payment/payment_cubit.dart';
import '../../../../shared/app_style.dart';
import '../../../../shared/snackBar/snack_bar.dart';
import '../../checkOutPage/check_out.dart';

class CheckoutButton extends StatelessWidget {
  CheckoutButton({
    super.key,
    required this.text,
    this.ontap,
    this.id,
    this.totalPrice,
    this.userId,
  });
  final String text;
  final void Function()? ontap;
  final int? id;
  final int? userId;
  bool isLoading = false;
  final int? totalPrice;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfirmCartCubit, ConfirmCartState>(
      listener: (context, state) {
        if (state is ConfirmCartLoading) {
          isLoading = true;
        } else if (state is ConfirmCartFailure) {
          isLoading = false;
          CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
        } else if (state is ConfirmCartSuccess) {
          isLoading = false;
          BlocProvider.of<PaymentCubit>(context)
              .checkout(totlePrice: state.confirmCart.order?.totalPrice ?? 0);
          Navigator.pushNamed(context, CheckOutPage.routName);
          CustomSnackBar.displaySuccessMotionToast(
              state.confirmCart.success ?? "", context);
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF242424),
              textStyle: appStyle(18, FontWeight.w500, Colors.black),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            onPressed: () async {
              print(id);
              await BlocProvider.of<ConfirmCartCubit>(context)
                  .confirmCart(id: id, userId: userId);
            },
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    text,
                  ),
          ),
        );
      },
    );
  }
}
