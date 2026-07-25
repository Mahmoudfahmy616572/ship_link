import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';

class SetNewPasswordWeb extends StatefulWidget {
  const SetNewPasswordWeb({super.key});
  static String routName = '/set-new-password';

  @override
  State<SetNewPasswordWeb> createState() => _SetNewPasswordWebState();
}

class _SetNewPasswordWebState extends State<SetNewPasswordWeb> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is UpdatePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t.tr('password_updated'))),
            );
            Navigator.pushNamedAndRemoveUntil(context, WelcomeWeb.routName, (_) => false);
          } else if (state is UpdatePasswordFaild) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.lock_outline, size: 48, color: AppColors.cta),
                    const SizedBox(height: 16),
                    Text(context.t.tr('set_new_password'), style: appStyle(28, FontWeight.w700, const Color(0xFF111827))),
                    const SizedBox(height: 8),
                    Text(context.t.tr('password_requirements'), style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                    const SizedBox(height: 32),
                    _buildField(
                      controller: _passwordCtrl,
                      hint: context.t.tr('new_password'),
                      obscure: _obscurePassword,
                      toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.t.tr('password_required');
                        if (v.length < 6) return context.t.tr('password_min_length');
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _confirmCtrl,
                      hint: context.t.tr('confirm_new_password'),
                      obscure: _obscureConfirm,
                      toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v != _passwordCtrl.text) return context.t.tr('passwords_do_not_match');
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final loading = state is UpdatePasswordLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: loading ? null : _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cta,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: loading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Text(context.t.tr('update_password'), style: appStyle(16, FontWeight.w600, Colors.white)),
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
    return TextFormField(
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
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9CA3AF)),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cta)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _updatePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().updatePassword(_passwordCtrl.text);
    }
  }
}
