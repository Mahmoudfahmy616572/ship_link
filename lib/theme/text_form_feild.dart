import 'package:flutter/material.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();
  static InputDecorationTheme lightTextFormTheme = InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Color(0xFFCDCDCD), fontSize: 13.5),
      suffixIconColor: Colors.white,
      prefixIconColor: Colors.white,
      filled: true,
      fillColor: const Color(0xFF151516));
  static InputDecorationTheme darkTextFormTheme = InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1),
      ),
      hintStyle: const TextStyle(color: Color(0xFFCDCDCD), fontSize: 13.5),
      suffixIconColor: Colors.white,
      prefixIconColor: Colors.white,
      filled: true,
      fillColor: const Color(0xFF151516));
}
