import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../constant/Errors/custom_error_widget.dart';
import '../../../../../cubits/payment/payment_cubit.dart';
import '../../../../shared/app_style.dart';
import '../../../../shared/snackBar/snack_bar.dart';
import '../../paymentWebView/payment_web_view.dart';

class CustomButton extends StatefulWidget {
  CustomButton({
    super.key,
    required this.totalPrice,
  });

  final int totalPrice;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        isLoading = true;
        if (state is PaymentLoading) {
          isLoading = true;
        } else if (state is PaymentSuccess) {
          isLoading = false;
        } else if (state is PaymentFailure) {
          CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
          isLoading = false;
        } else {
          const CustomErrorWidget(
            errMessage: "Error",
          );
          isLoading = false;
        }
      },
      builder: (context, state) {
        if (state is PaymentSuccess) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF242424),
                textStyle: appStyle(18, FontWeight.w500, Colors.black),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onPressed: () async {
                await BlocProvider.of<PaymentCubit>(context)
                    .checkout(totlePrice: widget.totalPrice);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WebPage(url: state.payment.url ?? "")),
                );
                CustomSnackBar.displaySuccessMotionToast(
                    state.payment.message ?? "", context);
              },
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Text(
                      "CheckOut",
                    ),
            ),
          );
        } else if (state is PaymentLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is PaymentFailure) {
          return CustomErrorWidget(errMessage: state.errMessage);
        } else {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF242424),
                textStyle: appStyle(18, FontWeight.w500, Colors.black),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onPressed: () {},
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Text(
                      "CheckOut",
                    ),
            ),
          );
        }
      },
    );
  }
}

class RowPrice extends StatelessWidget {
  const RowPrice({
    super.key,
    required this.text,
    required this.price,
  });
  final String text;
  final String price;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: appStyle(18, FontWeight.w600, Colors.black),
        ),
        Text(
          price,
          style: appStyle(18, FontWeight.w600, Colors.black),
        ),
      ],
    );
  }
}
