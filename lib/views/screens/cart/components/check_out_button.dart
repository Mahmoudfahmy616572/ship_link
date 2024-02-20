import 'package:flutter/material.dart';

import '../../../shared/app_style.dart';

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
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
            color: const Color(0xFF242424),
            borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            text,
            style: appStyle(18, FontWeight.w500, Colors.white),
          ),
        ),
      ),
    );
  }
}
