import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/utils/sizer.dart';

enum AuthFieldTheme { outline, filled }

/// Shared, themed text field used across all auth & profile forms.
/// Supports outline (light) and filled (primary) themes, an optional
/// persistent [label], a [suffix] widget (e.g. visibility toggle built by
/// the caller), focus chaining via [focusNode]/[onSubmitted], and safe
/// handling of obscured multiline fields.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.label,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onSubmitted,
    this.enabled = true,
    this.suffix,
    this.theme = AuthFieldTheme.outline,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? label;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final Widget? suffix;
  final AuthFieldTheme theme;

  @override
  Widget build(BuildContext context) {
    final filled = theme == AuthFieldTheme.filled;
    final textColor =
        filled ? AppColors.textOnPrimary : AppColors.textPrimary;
    final hintColor =
        filled ? AppColors.textSecondary : AppColors.textDisabled;
    final radius = filled ? 12.0 : 16.0;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius.r),
      borderSide:
          filled ? BorderSide.none : const BorderSide(color: AppColors.border),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius.r),
      borderSide: const BorderSide(color: AppColors.cta),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius.r),
      borderSide: const BorderSide(color: AppColors.error),
    );

    final field = TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLength: maxLength,
      maxLines: obscure ? 1 : maxLines,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: 14.sp, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
        prefixIcon: Icon(icon, color: hintColor),
        suffixIcon: suffix,
        filled: filled,
        fillColor: filled ? AppColors.primary : null,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: filled ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        field,
      ],
    );
  }
}
