import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/services/error_handler.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:ship_link/user/presentation/screens/create_account/create_account_screen.dart';
import 'package:ship_link/user/presentation/screens/MainScreen/main_screen.dart';
import 'package:ship_link/user/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:ship_link/core/utils/sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String routName = '/login';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _obscurePassword = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final email = await CredentialsService().loadEmail();
    final password = await CredentialsService().loadPassword();
    if (email != null && mounted) {
      _emailController.text = email;
    }
    if (password != null && mounted) {
      _passwordController.text = password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    CredentialsService().save(_emailController.text.trim(), password: _passwordController.text.trim());
    AuthCubit.get(context).signIN(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignInSuccess && mounted) {
            Navigator.pushReplacementNamed(
                context, MainScreen.routName);
          } else if (state is SignInFaild && mounted) {
            CustomSnackBar.error(ErrorHandler.getFriendlyMessage(state.message, context.t.tr), context);
          } else if (state is ErrorState && mounted) {
            CustomSnackBar.error(ErrorHandler.getFriendlyMessage(state.message, context.t.tr), context);
          }
        },
        builder: (context, state) {
          final isLoading = state is SignInLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      context.t.tr('login'),
                      style: GoogleFonts.inter(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      context.t.tr('sign_in_to_continue'),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    _buildLoginIllustration(),
                    SizedBox(height: 32.h),
                    _buildField(
                      controller: _emailController,
                      hint: context.t.tr('email'),
                      leading: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 254,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return context.t.tr('email_required');
                        if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                            .hasMatch(v)) {
                          return context.t.tr('valid_email');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscurePassword,
                      builder: (context, obscure, _) {
                        return _buildField(
                          controller: _passwordController,
                          hint: context.t.tr('password'),
                          leading: Icons.lock_outline,
                          obscure: obscure,
                          maxLength: 128,
                          trailing: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF9CA3AF),
                            ),
                            onPressed: () =>
                                _obscurePassword.value = !obscure,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return context.t.tr('password_required');
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, ResetPasswordScreen.routName),
                        child: Text(
                          context.t.tr('forgot_password'),
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
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
                            : Text(context.t.tr('login')),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    _buildSocialLogin(),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.t.tr('dont_have_account'),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontSize: 14.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, CreateAccountScreen.routName),
                          child: Text(
                            context.t.tr('register'),
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
          );
        },
      ),
    );
  }

  Widget _buildLoginIllustration() {
    return Container(
      width: 160.w,
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColors.cta.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_outline,
        size: 64,
        color: AppColors.cta,
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
    int? maxLength,
    int? maxLines,
  }) {
    return SizedBox(
      height: maxLines != null && maxLines > 1 ? null : 56.h,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        maxLines: maxLines,
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
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: AppColors.cta),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF6B7280))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                context.t.tr('or_continue_with'),
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 14.sp,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF6B7280))),
          ],
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: _socialButton(
            iconPath: 'assets/icons/googel icon.svg',
            label: context.t.tr('google'),
            onTap: () => AuthCubit.get(context).signInWithGoogle(),
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 20, height: 20),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
