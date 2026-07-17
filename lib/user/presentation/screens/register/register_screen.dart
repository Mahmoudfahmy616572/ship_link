import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:ship_link/core/services/error_handler.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/utils/validators.dart';
import 'package:ship_link/core/widgets/auth_field.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/screens/location_picker/location_picker.dart';
import 'package:ship_link/user/presentation/screens/sign_in/sign_in_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static String routName = '/register';
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirm = ValueNotifier<bool>(true);
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _register() {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AuthCubit.get(context).signUp(
      name: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Registersuccess && mounted) {
            setState(() => _submitting = false);
            CredentialsService().save(_emailController.text.trim());
            Navigator.pushReplacementNamed(context, LocationPicker.routName);
          } else if (state is Registerfaild && mounted) {
            setState(() => _submitting = false);
            CustomSnackBar.error(
                ErrorHandler.getFriendlyMessage(state.message, context.t.tr),
                context);
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading || _submitting;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.03),
                    Text(
                      context.t.tr('create_account'),
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      context.t.tr('fill_details'),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    _buildLabel(context.t.tr('username')),
                    SizedBox(height: size.height * 0.01),
                    AuthField(
                      controller: _usernameController,
                      hint: context.t.tr('enter_username'),
                      icon: Icons.person_outline,
                      maxLength: 50,
                      theme: AuthFieldTheme.filled,
                      focusNode: _usernameFocus,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: (v) => Validators.username(context, v),
                    ),
                    SizedBox(height: size.height * 0.025),
                    _buildLabel(context.t.tr('email')),
                    SizedBox(height: size.height * 0.01),
                    AuthField(
                      controller: _emailController,
                      hint: context.t.tr('enter_email'),
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 254,
                      theme: AuthFieldTheme.filled,
                      focusNode: _emailFocus,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) => Validators.email(context, v),
                    ),
                    SizedBox(height: size.height * 0.025),
                    _buildLabel(context.t.tr('password')),
                    SizedBox(height: size.height * 0.01),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscurePassword,
                      builder: (context, obscure, _) {
                        return AuthField(
                          controller: _passwordController,
                          hint: context.t.tr('enter_password'),
                          icon: Icons.lock_outline,
                          obscure: obscure,
                          maxLength: 128,
                          theme: AuthFieldTheme.filled,
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
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                _obscurePassword.value = !obscure,
                          ),
                          validator: (v) => Validators.password(context, v),
                        );
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    _buildLabel(context.t.tr('confirm_password')),
                    SizedBox(height: size.height * 0.01),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureConfirm,
                      builder: (context, obscure, _) {
                        return AuthField(
                          controller: _confirmPasswordController,
                          hint: context.t.tr('confirm_your_password'),
                          icon: Icons.lock_outline,
                          obscure: obscure,
                          maxLength: 128,
                          theme: AuthFieldTheme.filled,
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
                              color: AppColors.textSecondary,
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
                    SizedBox(height: size.height * 0.04),
                    SizedBox(
                      width: size.width * 0.85,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.03),
                                  Text(
                                    context.t.tr('creating_account'),
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                context.t.tr('register'),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, SignIn.routName);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: context.t.tr('already_have_account'),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: size.width * 0.035,
                            ),
                            children: [
                              TextSpan(
                                text: context.t.tr('sign_in'),
                                style: TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
