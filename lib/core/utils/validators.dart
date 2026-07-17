import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';

/// Centralized, reusable form validators for auth & profile screens.
/// One password policy is enforced everywhere via [passwordMinLength].
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

  /// Single source of truth for the minimum password length.
  static const int passwordMinLength = 8;

  static String? email(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.t.tr('email_required');
    if (!_emailRegex.hasMatch(v)) return context.t.tr('valid_email');
    return null;
  }

  static String? password(BuildContext context, String? value) {
    final v = value ?? '';
    if (v.isEmpty) return context.t.tr('password_required');
    if (v.length < passwordMinLength) {
      return context.t.tr('password_min_length');
    }
    return null;
  }

  static String? confirmPassword(
    BuildContext context,
    String? value,
    String? original,
  ) {
    final v = value ?? '';
    if (v.isEmpty) return context.t.tr('please_confirm_password');
    if (v != original) return context.t.tr('passwords_do_not_match');
    return null;
  }

  static String? name(
    BuildContext context,
    String? value, {
    String requiredKey = 'name_required',
    String shortKey = 'name_must_be_more_than_2',
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.t.tr(requiredKey);
    if (v.length < 3) return context.t.tr(shortKey);
    return null;
  }

  static String? username(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.t.tr('username_required');
    if (v.length < 3) return context.t.tr('username_min_length');
    return null;
  }

  static String? phone(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.t.tr('phone_required');
    if (v.length < 10) return context.t.tr('phone_invalid');
    return null;
  }

  static String? address(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.t.tr('address_required');
    if (v.length < 10) return context.t.tr('address_detailed');
    return null;
  }

  static String? postalCode(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.t.tr('postal_required');
    if (v.length < 4) return context.t.tr('postal_invalid');
    return null;
  }

  /// Strength score 0..4 used by the password strength meter.
  /// 1 point each for: length, mixed case, digit, special char.
  static int strength(String value) {
    if (value.isEmpty) {
      return 0;
    }
    int score = 0;
    if (value.length >= passwordMinLength) score++;
    if (RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#\$&*~^%()\-_=+\[\]{}|;:,.<>?]').hasMatch(value)) {
      score++;
    }
    return score;
  }

  static String strengthLabel(BuildContext context, int score) {
    if (score <= 1) return context.t.tr('password_weak');
    if (score == 2 || score == 3) return context.t.tr('password_medium');
    return context.t.tr('password_strong');
  }
}
