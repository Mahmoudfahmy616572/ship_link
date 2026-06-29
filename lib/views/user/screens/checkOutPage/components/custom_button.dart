import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/shared/app_style.dart';

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
        Text(text, style: appStyle(18, FontWeight.w600, Colors.black)),
        Text(price, style: appStyle(18, FontWeight.w600, Colors.black)),
      ],
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? const Color(0xFF242424) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? const Color(0xFF242424) : const Color(0xFF9CA3AF)),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
                  Text(subtitle, style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF242424) : const Color(0xFFD1D5DB),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
