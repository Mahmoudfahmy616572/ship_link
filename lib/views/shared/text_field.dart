import 'package:flutter/material.dart';
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
  });
  final String hintText;
  final bool obscureText;
  final TextInputType? textInputType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters,
      validator: validator,
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Color(0xFFCDCDCD)),
      keyboardType: textInputType,
      obscureText: obscureText,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFCDCDCD), fontSize: 13.5),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFF151516)),
    );
  }
}
