import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/web/presentation/services/auth_service_web.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/home/home_web.dart';
import 'package:ship_link/web/presentation/screens/register/register_web.dart';
import 'package:ship_link/core/utils/sizer.dart';

class LoginWeb extends StatefulWidget {
  const LoginWeb({super.key});
  static String routName = '/login';

  @override
  State<LoginWeb> createState() => _LoginWebState();
}

class _LoginWebState extends State<LoginWeb> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthServiceWeb>();
    final isWide = MediaQuery.of(context).size.width > 900;

    if (isWide) {
      return Row(
        children: [
          Expanded(
            child: _buildHeroSide(context),
          ),
          Expanded(
            child: _buildFormSide(context, auth),
          ),
        ],
      );
    }

    return _buildFormSide(context, auth);
  }

  Widget _buildHeroSide(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
      ),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 44),
                ),
                SizedBox(height: 24),
                Text('ShipLink', style: appStyle(36, FontWeight.w700, Colors.white)),
                SizedBox(height: 12),
                Text(context.t.tr('shop_description'),
                    style: appStyle(16, FontWeight.w400, Colors.white70), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSide(BuildContext context, AuthServiceWeb auth) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.t.tr('sign_in'), style: appStyle(32, FontWeight.w700, const Color(0xFF111827))),
                SizedBox(height: 8),
                Text(context.t.tr('sign_in_subtitle'),
                    style: appStyle(15, FontWeight.w400, const Color(0xFF6B7280))),
                SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: context.t.tr('email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? context.t.tr('email_required') : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: context.t.tr('password'),
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? context.t.tr('password_required') : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<AuthServiceWeb>().sendPasswordReset(_emailCtrl.text),
                  child: Text('Forgot password?', style: appStyle(13, FontWeight.w500, AppColors.primary)),
                ),
                SizedBox(height: 16),
                if (auth.error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(auth.error!, style: appStyle(13, FontWeight.w500, AppColors.error)),
                  ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthServiceWeb>().signIn(
                          email: _emailCtrl.text,
                          password: _passwordCtrl.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: auth.status == WebAuthStatus.uninitialized
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(context.t.tr('sign_in'), style: appStyle(16, FontWeight.w600, Colors.white)),
                  ),
                ),
                if (auth.error == null) SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<AuthServiceWeb>().signInWithGoogle(),
                    icon: const Icon(Icons.login, size: 20),
                    label: Text(context.t.tr('continue_with_google')),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.t.tr('no_account'),
                        style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RegisterWeb.routName),
                      child: Text(context.t.tr('sign_up'),
                          style: appStyle(14, FontWeight.w600, AppColors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
