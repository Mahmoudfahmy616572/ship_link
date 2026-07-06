import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:flutter/services.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    this.textInputType,
    this.suffixIcon,
    this.validator,
    this.controller,
    this.inputFormatters,
    this.maxLength,
    this.maxLines,
  });
  final String hintText;
  final bool obscureText;
  final TextInputType? textInputType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: validator,
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Color(0xFFCDCDCD)),
      keyboardType: textInputType,
      obscureText: obscureText,
      decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFFCDCDCD), fontSize: 13.5.sp),
          suffixIcon: suffixIcon,
          suffixIconColor: Colors.white,
          prefixIconColor: Colors.white,
          filled: true,
          fillColor: const Color(0xFF151516)),
    );
  }
}
