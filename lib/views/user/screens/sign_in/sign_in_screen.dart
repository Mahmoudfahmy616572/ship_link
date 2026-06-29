import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/services/cache_service.dart';
import 'package:ship_link/views/user/screens/location_picker/location_picker.dart';
import 'package:ship_link/views/user/screens/register/register_screen.dart';
import 'package:ship_link/utils/sizer.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  static String routName = '/signIn';
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadSavedCredentials() async {
    final email = await CredentialsService().load();
    if (email != null && mounted) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    CredentialsService().save(_emailController.text.trim());
    AuthCubit.get(context).signIN(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignInSuccess && mounted) {
            Navigator.pushReplacementNamed(
                context, LocationPicker.routName);
          } else if (state is SignInFaild && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ErrorState && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SignInLoading;
          return SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.08),
                    Center(
                      child: Text(
                        context.t.tr('app_name'),
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: size.width * 0.12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Center(
                      child: Text(
                        context.t.tr('your_delivery_partner'),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.07),
                    Text(
                      context.t.tr('welcome_back'),
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      context.t.tr('sign_in_to_continue'),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    _buildLabel(context.t.tr('email')),
                    SizedBox(height: size.height * 0.01),
                    _buildField(
                      controller: _emailController,
                      hint: context.t.tr('enter_email'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
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
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return context.t.tr('password_required');
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
                                onPressed: isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
                                              context.t.tr('signing_in'),
                                              style: TextStyle(
                                                fontSize: 17.sp,
                                                color: AppColors.textOnPrimary,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          context.t.tr('sign_in'),
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
                          Navigator.pushNamed(
                              context, RegisterScreen.routName);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: context.t.tr('dont_have_account'),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: size.width * 0.035,
                            ),
                            children: [
                              TextSpan(
                                text: context.t.tr('register'),
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
