import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/web/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';
import 'package:ship_link/core/utils/sizer.dart';

class CreateAccountWeb extends StatefulWidget {
  const CreateAccountWeb({super.key});
  static String routName = '/create-account';

  @override
  State<CreateAccountWeb> createState() => _CreateAccountWebState();
}

class _CreateAccountWebState extends State<CreateAccountWeb> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.tr('please_agree_terms'))));
      return;
    }
    AuthCubit.get(context).signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)), onPressed: () => Navigator.pop(context)),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Registersuccess && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.tr('registration_success_check_email'))));
            Navigator.pushReplacementNamed(context, WelcomeWeb.routName);
          }
          if (state is Registerfaild && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message.isNotEmpty ? state.message : context.t.tr('registration_failed'))));
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(context.t.tr('create_account'), style: appStyle(32, FontWeight.w700, const Color(0xFF111827))),
                    SizedBox(height: 12),
                    Text(context.t.tr('create_account_subtitle'), style: appStyle(16, FontWeight.w400, const Color(0xFF6B7280))),
                    SizedBox(height: 32),
                    _buildIllustration(),
                    SizedBox(height: 32),
                    _field(context.t.tr('full_name'), _nameCtrl, Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? context.t.tr('name_required') : null),
                    SizedBox(height: 12),
                    _field(context.t.tr('email'), _emailCtrl, Icons.mail_outline, keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t.tr('email_required');
                          if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(v)) return context.t.tr('valid_email');
                          return null;
                        }),
                    SizedBox(height: 12),
                    _field(context.t.tr('password'), _passwordCtrl, Icons.lock_outline, obscure: _obscurePass,
                        trailing: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF)),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t.tr('password_required');
                          if (v.length < 6) return context.t.tr('password_min_length');
                          return null;
                        }),
                    SizedBox(height: 12),
                    _field(context.t.tr('confirm_password'), _confirmCtrl, Icons.lock_outline, obscure: _obscureConfirm,
                        trailing: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF)),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t.tr('please_confirm_password');
                          if (v != _passwordCtrl.text) return context.t.tr('passwords_do_not_match');
                          return null;
                        }),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          height: 24, width: 24,
                          child: Checkbox(
                            value: _agreeTerms,
                            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                            activeColor: AppColors.cta,
                            side: const BorderSide(color: Color(0xFF6B7280)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(child: Text(context.t.tr('i_agree_terms'), style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280)))),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(context.t.tr('create_account'), style: appStyle(16, FontWeight.w600, Colors.white)),
                      ),
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.t.tr('already_have_account'), style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                        GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, WelcomeWeb.routName),
                          child: Text(context.t.tr('login'), style: appStyle(14, FontWeight.w600, AppColors.cta)),
                        ),
                      ],
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

  Widget _buildIllustration() {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(color: AppColors.cta.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(Icons.person_outline, size: 56, color: AppColors.cta),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false, Widget? trailing, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return SizedBox(
      height: 56,
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: appStyle(14, FontWeight.w400, const Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: appStyle(14, FontWeight.w400, const Color(0xFF9CA3AF)),
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
          suffixIcon: trailing,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cta)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
