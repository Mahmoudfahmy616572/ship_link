import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/web/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/web/presentation/screens/create_account/create_account_web.dart';
import 'package:ship_link/core/utils/sizer.dart';

class WelcomeWeb extends StatefulWidget {
  const WelcomeWeb({super.key});
  static String routName = '/welcome';

  @override
  State<WelcomeWeb> createState() => _WelcomeWebState();
}

class _WelcomeWebState extends State<WelcomeWeb> {
  bool _showLoginForm = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 40),
              _buildLogo(),
              SizedBox(height: 40),
              if (!_showLoginForm) ...[
                Text(context.t.tr('welcome_to_shopease'),
                    style: appStyle(36, FontWeight.w700, const Color(0xFF111827)),
                    textAlign: TextAlign.center),
                SizedBox(height: 16),
                SizedBox(
                  width: 280,
                  child: Text(context.t.tr('discover_best_products'),
                      style: appStyle(16, FontWeight.w400, const Color(0xFF6B7280)),
                      textAlign: TextAlign.center),
                ),
                SizedBox(height: 48),
                _buildIllustration(),
                SizedBox(height: 48),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showLoginForm = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(context.t.tr('login'), style: appStyle(16, FontWeight.w600, Colors.white)),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, CreateAccountWeb.routName),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cta,
                      side: const BorderSide(color: AppColors.cta, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(context.t.tr('create_account'), style: appStyle(16, FontWeight.w600, AppColors.cta)),
                  ),
                ),
                SizedBox(height: 32),
                _buildSocialSection(),
              ] else ...[
                _buildLoginForm(),
              ],
              if (!_showLoginForm) ...[
                SizedBox(height: 24),
                SizedBox(
                  width: 280,
                  child: Text(context.t.tr('by_continuing_agree'),
                      style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280)),
                      textAlign: TextAlign.center),
                ),
                SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignInSuccess && mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        if (state is SignInFaild && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is SignInLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(context.t.tr('sign_in'), style: appStyle(28, FontWeight.w700, const Color(0xFF111827))),
            SizedBox(height: 8),
            Text(context.t.tr('sign_in_to_continue'), style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
            SizedBox(height: 32),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.t.tr('email_hint'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.t.tr('password'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : () => AuthCubit.get(context).signIN(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: loading
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.t.tr('sign_in'), style: appStyle(16, FontWeight.w600, Colors.white)),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/reset-password'),
                child: Text(context.t.tr('forgot_password'), style: TextStyle(color: AppColors.cta)),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _showLoginForm = false),
                child: Text(context.t.tr('back'), style: TextStyle(color: const Color(0xFF6B7280))),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.cta),
        SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: context.t.tr('shop'),
            style: appStyle(36, FontWeight.w700, const Color(0xFF111827)),
            children: [TextSpan(text: context.t.tr('ease'), style: TextStyle(color: AppColors.cta))],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 260, height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 20, top: 10,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: AppColors.cta.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.card_giftcard_outlined, size: 36, color: AppColors.cta),
            ),
          ),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: AppColors.cta.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.cta),
          ),
          Positioned(right: 15, bottom: 15,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.cta.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(22)),
              child: Icon(Icons.shopping_cart_outlined, size: 40, color: AppColors.cta),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is NewGoogleUser && mounted) {
          Navigator.pushReplacementNamed(context, CreateAccountWeb.routName);
        }
        if (state is SuccessState && mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        if (state is ErrorState && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFF6B7280))),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(context.t.tr('or_continue_with'), style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280)))),
                const Expanded(child: Divider(color: Color(0xFF6B7280))),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _socialButton(Icons.g_mobiledata, context.t.tr('google'), () => AuthCubit.get(context).signInWithGoogle())),
                SizedBox(width: 12),
                Expanded(child: _socialButton(Icons.apple, context.t.tr('apple'), () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.tr('coming_soon'))));
                })),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _socialButton(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            SizedBox(width: 8),
            Text(label, style: appStyle(14, FontWeight.w500, const Color(0xFF111827))),
          ],
        ),
      ),
    );
  }
}
