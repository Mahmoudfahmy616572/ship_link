import 'package:flutter/material.dart';

class Sizer {
  static late double width;
  static late double height;

  static const double _maxDesignWidth = 480;
  static const double _maxDesignHeight = 960;

  static double get safeWidth => width > _maxDesignWidth ? _maxDesignWidth : width;
  static double get safeHeight => height > _maxDesignHeight ? _maxDesignHeight : height;

  static void init(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }
}

extension NumExtension on num {
  double get h => this / 812 * Sizer.safeHeight;
  double get w => this / 375 * Sizer.safeWidth;
  double get sp => this / 375 * Sizer.safeWidth;
  double get r => this / 375 * Sizer.safeWidth;
}
