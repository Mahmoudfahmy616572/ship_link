import 'package:flutter/material.dart';

// متحكّم الثيم الداكن للأدمن (مشترك بين كل الشاشات)
class AdminThemeMode {
  static final ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

  static const Color _darkBg = Color(0xFF0F1115);
  static const Color _darkSurface = Color(0xFF1A1D23);
  static const Color _darkBorder = Color(0xFF2A2E37);

  // خلفية الصفحة
  static Color bg(bool dark) => dark ? _darkBg : const Color(0xFFF5F6F8);

  // لون الكارت/الجدول
  static Color surface(bool dark) => dark ? _darkSurface : Colors.white;

  // لون الحدود
  static Color border(bool dark) => dark ? _darkBorder : const Color(0xFFE5E7EB);

  // لون النص الأساسي
  static Color textPrimary(bool dark) => dark ? const Color(0xFFE5E7EB) : const Color(0xFF111827);

  // لون النص الثانوي
  static Color textSecondary(bool dark) => dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

  // أيقونات/ألوان معطّلة
  static Color disabled(bool dark) => dark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF);
}
