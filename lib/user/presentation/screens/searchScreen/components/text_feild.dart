import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
    required this.onChanged,
  });
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      style: appStyle(16, FontWeight.normal, AppColors.textPrimary),
      decoration: InputDecoration(
          hintText: context.t.tr('search_products'),
          hintStyle: appStyle(16, FontWeight.normal, AppColors.textHint),
          suffixIcon: const Icon(Icons.search_outlined, color: AppColors.textSecondary),
          contentPadding: EdgeInsets.all(12.w),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: AppColors.surface),
    );
  }
}
