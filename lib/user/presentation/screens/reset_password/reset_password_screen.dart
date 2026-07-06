import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/build_elevation_button.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/user/presentation/screens/login/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  static String routName = '/resetPassword';
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _isLoading = ValueNotifier<bool>(false);
  final _isSent = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    _isLoading.value = true;
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'io.supabase.flutter://callback',
      );
      if (mounted) _isSent.value = true;
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error('${context.t.tr('failed_send_reset')}: $e', context);
      }
    } finally {
      if (mounted) _isLoading.value = false;
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  context.t.tr('reset_password'),
                  style: GoogleFonts.inter(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: 300.w,
                  child: Text(
                    context.t.tr('reset_password_subtitle'),
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 32.h),
                _buildResetIllustration(),
                SizedBox(height: 32.h),
                _buildField(
                  controller: _emailController,
                  hint: context.t.tr('email'),
                  leading: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.t.tr('email_required');
                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                        .hasMatch(v)) {
                      return context.t.tr('valid_email');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(context.t.tr('send_reset_link')),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24.h),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSent,
                  builder: (context, isSent, _) {
                    if (isSent) return _buildSuccessBox();
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.t.tr('remember_password'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, LoginScreen.routName),
                        child: Text(
                          context.t.tr('login'),
                        style: GoogleFonts.inter(
                          color: AppColors.cta,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetIllustration() {
    return SizedBox(
      width: 160.w,
      height: 160.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.cta.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mail_outline,
              size: 56,
              color: AppColors.cta,
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 28,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 24),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              context.t.tr('check_inbox'),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData leading,
    bool obscure = false,
    Widget? trailing,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 56.h,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(leading, color: const Color(0xFF9CA3AF)),
          suffixIcon: trailing,
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
