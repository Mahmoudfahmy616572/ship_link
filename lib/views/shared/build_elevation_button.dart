import 'package:flutter/material.dart';

import 'app_style.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({
    super.key,
    required this.text,
    this.ontap,
  });
  final String text;
  final void Function()? ontap;
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
        child: Text(
          text,
          // style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
