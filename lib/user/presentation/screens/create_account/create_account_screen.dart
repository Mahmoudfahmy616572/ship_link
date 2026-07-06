import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:ship_link/user/presentation/screens/location_picker/location_picker.dart';
import 'package:ship_link/user/presentation/screens/login/login_screen.dart';
import 'package:ship_link/core/utils/sizer.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms.value) {
      CustomSnackBar.info(context.t.tr('please_agree_terms'), context);
      return;
    }
    AuthCubit.get(context).signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: '',
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
          if (state is Registersuccess && mounted) {
            CredentialsService().save(_emailController.text.trim(), password: _passwordController.text.trim());
            Navigator.pushReplacementNamed(
                context, LocationPicker.routName);
          } else if (state is Registerfaild && mounted) {
            CustomSnackBar.error(state.message.isNotEmpty
                ? state.message
                : context.t.tr('registration_failed'), context);
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;
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
                    _buildField(
                      controller: _nameController,
                      hint: context.t.tr('full_name'),
                      leading: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return context.t.tr('name_required');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
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
                    SizedBox(height: 12.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscurePassword,
                      builder: (context, obscure, _) {
                        return _buildField(
                          controller: _passwordController,
                          hint: context.t.tr('password'),
                          leading: Icons.lock_outline,
                          obscure: obscure,
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
                            if (v.length < 6) {
                              return context.t.tr('password_min_length');
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureConfirm,
                      builder: (context, obscure, _) {
                        return _buildField(
                          controller: _confirmPasswordController,
                          hint: context.t.tr('confirm_password'),
                          leading: Icons.lock_outline,
                          obscure: obscure,
                          trailing: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF9CA3AF),
                            ),
                            onPressed: () =>
                                _obscureConfirm.value = !obscure,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return context.t.tr('please_confirm_password');
                            }
                            if (v != _passwordController.text) {
                              return context.t.tr('passwords_do_not_match');
                            }
                            return null;
                          },
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
                              child: Text(
                                context.t.tr('i_agree_terms'),
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF6B7280),
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
                                child: CircularProgressIndicator(
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
}
