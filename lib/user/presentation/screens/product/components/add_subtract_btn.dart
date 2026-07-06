import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/utils/sizer.dart';

class AddOrSubtractButton extends StatelessWidget {
  const AddOrSubtractButton({
    super.key,
    required this.ontap,
    required this.icon,
  });
  final void Function()? ontap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(55),
      onTap: ontap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cta,
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}
