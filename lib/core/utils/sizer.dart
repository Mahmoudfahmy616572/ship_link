import 'package:flutter/material.dart';

class Sizer {
  static late double width;
  static late double height;

  static void init(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }
}

extension NumExtension on num {
  double get h => this / 812 * Sizer.height;
  double get w => this / 375 * Sizer.width;
  double get sp => this / 375 * Sizer.width;
  double get r => this / 375 * Sizer.width;
}
