import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/build_elevation_button.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/utils/sizer.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});
  static String routName = '/setNewPassword';

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirm = ValueNotifier(true);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UpdatePasswordSuccess) {
          CustomSnackBar.displaySuccessMotionToast(
              context.t.tr('password_updated'), context);
          Navigator.pushNamedAndRemoveUntil(
              context, '/', (_) => false);
        } else if (state is UpdatePasswordFaild) {
          CustomSnackBar.displayErrorMotionToast(state.message, context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Icon(Icons.lock_outline, size: 48, color: AppColors.cta),
                  SizedBox(height: 16.h),
                  Text(
                    context.t.tr('set_new_password'),
                    style: appStyle(28, FontWeight.w700, const Color(0xFF111827)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.t.tr('password_requirements'),
                    style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 32.h),
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscurePassword,
                    builder: (context, obscure, _) => _buildField(
                      controller: _passwordCtrl,
                      hint: context.t.tr('new_password'),
                      obscure: obscure,
                      toggleObscure: () => _obscurePassword.value = !_obscurePassword.value,
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.t.tr('password_required');
                        if (v.length < 6) return context.t.tr('password_min_length');
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscureConfirm,
                    builder: (context, obscure, _) => _buildField(
                      controller: _confirmCtrl,
                      hint: context.t.tr('confirm_new_password'),
                      obscure: obscure,
                      toggleObscure: () => _obscureConfirm.value = !_obscureConfirm.value,
                      validator: (v) {
                        if (v != _passwordCtrl.text) return context.t.tr('passwords_do_not_match');
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final loading = state is UpdatePasswordLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthCubit>().updatePassword(_passwordCtrl.text);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cta,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: loading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  context.t.tr('update_password'),
                                  style: appStyle(16, FontWeight.w600, Colors.white),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 56.h,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: appStyle(14, FontWeight.w500, const Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: appStyle(14, FontWeight.w400, const Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9CA3AF)),
            onPressed: toggleObscure,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.cta),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }
}
