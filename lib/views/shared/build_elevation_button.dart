// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';

import 'app_style.dart';
import 'snackBar/snack_bar.dart';

class CheckoutButton extends StatelessWidget {
  CheckoutButton({
    super.key,
    required this.text,
    this.ontap,
    this.id,
  });
  final String text;
  final void Function()? ontap;
  final int? id;
  bool isLoading = false;
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
          CustomSnackBar.displaySuccessMotionToast(state.success, context);
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
            onPressed: () {
              print(id);
              BlocProvider.of<ConfirmCartCubit>(context).confirmCart(id: id);
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
