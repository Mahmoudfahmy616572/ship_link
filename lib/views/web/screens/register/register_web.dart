import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/services/auth_service_web.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/web/screens/home/home_web.dart';
import 'package:ship_link/utils/sizer.dart';

class RegisterWeb extends StatefulWidget {
  const RegisterWeb({super.key});
  static String routName = '/register';

  @override
  State<RegisterWeb> createState() => _RegisterWebState();
}

class _RegisterWebState extends State<RegisterWeb> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<AuthServiceWeb>().signUp(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (mounted) {
      setState(() => _loading = false);
      final auth = context.read<AuthServiceWeb>();
      if (auth.status == WebAuthStatus.authenticated) {
        Navigator.pushNamedAndRemoveUntil(context, HomeWeb.routName, (_) => false);
      } else if (auth.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t.tr('create_account'),
                      style: appStyle(32, FontWeight.w700, const Color(0xFF111827))),
                  SizedBox(height: 8.h),
                  Text(context.t.tr('sign_up_subtitle'),
                      style: appStyle(16, FontWeight.w400, const Color(0xFF6B7280))),
                  SizedBox(height: 32.h),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: context.t.tr('full_name'),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? context.t.tr('name_required')
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: context.t.tr('email'),
                      prefixIcon: const Icon(Icons.mail_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? context.t.tr('email_required')
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: context.t.tr('password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.t.tr('password_required');
                      if (v.length < 6) return context.t.tr('password_min_length');
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(context.t.tr('create_account'),
                              style: appStyle(16, FontWeight.w600, Colors.white)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.t.tr('have_account'),
                          style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.t.tr('sign_in'),
                            style: appStyle(14, FontWeight.w600, AppColors.cta)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
