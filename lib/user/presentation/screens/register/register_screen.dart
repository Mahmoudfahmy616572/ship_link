import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/services/error_handler.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:ship_link/user/presentation/screens/location_picker/location_picker.dart';
import 'package:ship_link/user/presentation/screens/sign_in/sign_in_screen.dart';
import 'package:ship_link/core/utils/sizer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static String routName = '/register';
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
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
            CredentialsService().save(_emailController.text.trim(), password: _passwordController.text.trim());
            Navigator.pushReplacementNamed(
                context, LocationPicker.routName);
          } else if (state is Registerfaild && mounted) {
            CustomSnackBar.error(
                ErrorHandler.getFriendlyMessage(state.message, context.t.tr), context);
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;
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
                    _buildField(
                      controller: _usernameController,
                      hint: context.t.tr('enter_username'),
                      icon: Icons.person_outline,
                      maxLength: 50,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return context.t.tr('username_required');
                        }
                        if (v.trim().length < 3) {
                          return context.t.tr('username_min_length');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    _buildLabel(context.t.tr('email')),
                    SizedBox(height: size.height * 0.01),
                    _buildField(
                      controller: _emailController,
                      hint: context.t.tr('enter_email'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 254,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return context.t.tr('email_required');
                        }
                        if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                            .hasMatch(v)) {
                          return context.t.tr('valid_email');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    _buildLabel(context.t.tr('password')),
                    SizedBox(height: size.height * 0.01),
                    _buildField(
                      controller: _passwordController,
                      hint: context.t.tr('enter_password'),
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      maxLength: 128,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.t.tr('password_required');
                        if (v.length < 8) {
                          return context.t.tr('password_min_length');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    _buildLabel(context.t.tr('confirm_password')),
                    SizedBox(height: size.height * 0.01),
                    _buildField(
                      controller: _confirmPasswordController,
                      hint: context.t.tr('confirm_your_password'),
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirm,
                      maxLength: 128,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.t.tr('please_confirm_password');
                        if (v.length < 8) return context.t.tr('password_min_length');
                        if (v != _passwordController.text) {
                          return context.t.tr('passwords_do_not_match');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.04),
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isLoading ? _pulseAnimation.value : 1.0,
                            child: SizedBox(
                              width: size.width * 0.85,
                              height: 56.h,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: isLoading ? 0 : 4,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: isLoading
                                      ? Row(
                                          key: const ValueKey('loading'),
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 24.w,
                                              height: 24.h,
                                              child: CircularProgressIndicator(
                                                color: AppColors.textOnPrimary,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                            SizedBox(width: size.width * 0.03),
                                            Text(
                                              context.t.tr('creating_account'),
                                              style: TextStyle(
                                                fontSize: 17.sp,
                                                color: AppColors.textOnPrimary,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          context.t.tr('register'),
                                          key: ValueKey('text'),
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: AppColors.textOnPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
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
                                  color: AppColors.primary,
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
        color: AppColors.textSecondary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: AppColors.textOnPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
      ),
    );
  }
}
