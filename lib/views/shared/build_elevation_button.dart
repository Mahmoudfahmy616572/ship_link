// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'app_style.dart';

class CheckoutButton extends StatelessWidget {
  CheckoutButton({
    super.key,
    required this.text,
    this.ontap,
    this.id,
    this.totalPrice,
  });
  final String text;
  final void Function()? ontap;
  final int? id;
  bool isLoading = false;
  final int? totalPrice;
  @override
  Widget build(BuildContext context) {
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
        onPressed: ontap,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Text(
                text,
              ),
      ),
    );
  }
}
