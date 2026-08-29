import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/utils/validators.dart';
import 'package:ship_link/core/widgets/auth_field.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/screens/login/login_screen.dart';
import 'package:ship_link/user/presentation/screens/otp/otp_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  static String routName = '/createAccount';
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirm = ValueNotifier<bool>(true);
  final _agreeTerms = ValueNotifier<bool>(false);
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    _agreeTerms.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _register() {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms.value) {
      CustomSnackBar.info(context.t.tr('please_agree_terms'), context);
      return;
    }
    setState(() => _submitting = true);
    AuthCubit.get(context).sendRegistrationOtp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Widget _strengthMeter() {
    return ListenableBuilder(
      listenable: _passwordController,
      builder: (context, _) {
        final ctrl = _passwordController;
        final score = Validators.strength(ctrl.text);
        final color = switch (score) {
          0 || 1 => AppColors.error,
          2 || 3 => AppColors.pending,
          _ => AppColors.success,
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    height: 4.h,
                    margin: EdgeInsets.only(right: i < 3 ? 6.w : 0),
                    decoration: BoxDecoration(
                      color: i < score ? color : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                );
              }),
            ),
            if (ctrl.text.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                '${context.t.tr('password_strength')}: ${Validators.strengthLabel(context, score)}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
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
          if (state is OtpSendSuccess && mounted) {
            setState(() => _submitting = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  email: _emailController.text.trim(),
                ),
              ),
            );
          } else if (state is OtpSendFaild && mounted) {
            setState(() => _submitting = false);
            CustomSnackBar.error(
                state.message.isNotEmpty
                    ? state.message
                    : context.t.tr('registration_failed'),
                context);
          }
        },
        builder: (context, state) {
          final isLoading = state is OtpSendLoading || _submitting;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      context.t.tr('create_account'),
                      style: GoogleFonts.inter(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      context.t.tr('create_account_subtitle'),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    _buildRegisterIllustration(),
                    SizedBox(height: 32.h),
                    AuthField(
                      controller: _nameController,
                      label: context.t.tr('full_name'),
                      hint: context.t.tr('enter_full_name'),
                      icon: Icons.person_outline,
                      focusNode: _nameFocus,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: (v) => Validators.name(context, v),
                    ),
                    SizedBox(height: 16.h),
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthField(
                              controller: _passwordController,
                              label: context.t.tr('password'),
                              hint: context.t.tr('enter_password'),
                              icon: Icons.lock_outline,
                              obscure: obscure,
                              maxLength: 128,
                              focusNode: _passwordFocus,
                              onSubmitted: (_) => _confirmFocus.requestFocus(),
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
                              validator: (v) =>
                                  Validators.password(context, v),
                            ),
                            _strengthMeter(),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureConfirm,
                      builder: (context, obscure, _) {
                        return AuthField(
                          controller: _confirmPasswordController,
                          label: context.t.tr('confirm_password'),
                          hint: context.t.tr('enter_confirm_password'),
                          icon: Icons.lock_outline,
                          obscure: obscure,
                          maxLength: 128,
                          focusNode: _confirmFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _register(),
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
                                _obscureConfirm.value = !obscure,
                          ),
                          validator: (v) => Validators.confirmPassword(
                            context,
                            v,
                            _passwordController.text,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: _agreeTerms,
                      builder: (context, agreeTerms, _) {
                        return Row(
                          children: [
                            SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: Checkbox(
                                value: agreeTerms,
                                onChanged: (v) =>
                                    _agreeTerms.value = v ?? false,
                                activeColor: AppColors.cta,
                                side: const BorderSide(color: Color(0xFF6B7280)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _agreeTerms.value = !agreeTerms,
                                child: Text(
                                  context.t.tr('i_agree_terms'),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
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
                        onPressed: isLoading ? null : _register,
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
                            : Text(context.t.tr('create_account')),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.t.tr('already_have_account'),
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
          );
        },
      ),
    );
  }

  Widget _buildRegisterIllustration() {
    return Container(
      width: 160.w,
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        size: 64,
        color: AppColors.primary,
      ),
    );
  }
}
