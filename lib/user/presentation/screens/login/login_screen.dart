import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/services/error_handler.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/utils/validators.dart';
import 'package:ship_link/core/widgets/auth_field.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/screens/create_account/create_account_screen.dart';
import 'package:ship_link/user/presentation/screens/MainScreen/main_screen.dart';
import 'package:ship_link/user/presentation/screens/reset_password/reset_password_screen.dart';

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
  final _rememberMe = ValueNotifier<bool>(false);
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final email = await CredentialsService().loadEmail();
    if (email != null && mounted) {
      _emailController.text = email;
      _rememberMe.value = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _rememberMe.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _login() {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    if (_rememberMe.value) {
      CredentialsService().save(_emailController.text.trim());
    } else {
      CredentialsService().clear();
    }
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
            setState(() => _submitting = false);
            Navigator.pushReplacementNamed(context, MainScreen.routName);
          } else if ((state is SignInFaild || state is ErrorState) && mounted) {
            setState(() => _submitting = false);
            final msg = state is SignInFaild
                ? state.message
                : (state as ErrorState).message;
            CustomSnackBar.error(
                ErrorHandler.getFriendlyMessage(msg, context.t.tr), context);
          }
        },
        builder: (context, state) {
          final isLoading = state is SignInLoading || _submitting;
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
                    AuthField(
                      controller: _emailController,
                      label: context.t.tr('email'),
                      hint: context.t.tr('enter_email'),
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 254,
                      focusNode: _emailFocus,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) => Validators.email(context, v),
                    ),
                    SizedBox(height: 16.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscurePassword,
                      builder: (context, obscure, _) {
                        return AuthField(
                          controller: _passwordController,
                          label: context.t.tr('password'),
                          hint: context.t.tr('enter_password'),
                          icon: Icons.lock_outline,
                          obscure: obscure,
                          maxLength: 128,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          suffix: IconButton(
                            tooltip: obscure
                                ? context.t.tr('show_password')
                                : context.t.tr('hide_password'),
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF9CA3AF),
                            ),
                            onPressed: () =>
                                _obscurePassword.value = !obscure,
                          ),
                          validator: (v) => Validators.password(context, v),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: _rememberMe,
                      builder: (context, remember, _) {
                        return Row(
                          children: [
                            SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: Checkbox(
                                value: remember,
                                onChanged: (v) => _rememberMe.value = v ?? false,
                                activeColor: AppColors.cta,
                                side: const BorderSide(color: Color(0xFF6B7280)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              context.t.tr('remember_me'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6B7280),
                                fontSize: 14.sp,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
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
                          ],
                        );
                      },
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
                                child: const CircularProgressIndicator(
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
      child: const Icon(
        Icons.lock_outline,
        size: 64,
        color: AppColors.cta,
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
