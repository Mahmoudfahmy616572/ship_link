import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';

class BuildTextFeild extends StatelessWidget {
  const BuildTextFeild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            hintText: context.t.tr('search'),
            hintStyle: const TextStyle(color: AppColors.textHint),
            suffixIcon: const Icon(Icons.search_outlined),
            suffixIconColor: AppColors.textHint,
            contentPadding: EdgeInsets.all(10.w),
            border: InputBorder.none,
            filled: true,
            enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 2.0),
                borderRadius: BorderRadius.circular(5.r)),
            // InputBorder.none,
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.r)),
            fillColor: AppColors.searchBg),
      ),
    );
  }
}
