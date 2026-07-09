import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/utils/sizer.dart';

class ResetPasswordWeb extends StatefulWidget {
  const ResetPasswordWeb({super.key});
  static String routName = '/reset-password';

  @override
  State<ResetPasswordWeb> createState() => _ResetPasswordWebState();
}

class _ResetPasswordWebState extends State<ResetPasswordWeb> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailCtrl.text.trim(),
        redirectTo: 'io.supabase.flutter://callback',
      );
      if (mounted) setState(() => _isSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.t.tr('failed_send_reset')}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(context.t.tr('reset_password'), style: appStyle(32, FontWeight.w700, const Color(0xFF111827))),
                SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: Text(context.t.tr('reset_password_subtitle'), style: appStyle(16, FontWeight.w400, const Color(0xFF6B7280)), textAlign: TextAlign.center),
                ),
                SizedBox(height: 32),
                _buildIllustration(),
                SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.t.tr('email_required');
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(v)) return context.t.tr('valid_email');
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: appStyle(14, FontWeight.w400, const Color(0xFF111827)),
                    decoration: InputDecoration(
                      hintText: context.t.tr('email'),
                      hintStyle: appStyle(14, FontWeight.w400, const Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF9CA3AF)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cta)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(context.t.tr('send_reset_link'), style: appStyle(16, FontWeight.w600, Colors.white)),
                  ),
                ),
                SizedBox(height: 24),
                if (_isSent) _buildSuccessBox(),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.t.tr('remember_password'), style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
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
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: AppColors.cta.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.mail_outline, size: 56, color: AppColors.cta),
          ),
          Positioned(right: 10, bottom: 10,
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: AppColors.cta.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.shield_outlined, size: 28, color: AppColors.cta),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
          SizedBox(width: 12),
          Expanded(child: Text(context.t.tr('check_inbox'), style: appStyle(14, FontWeight.w500, const Color(0xFF065F46)))),
        ],
      ),
    );
  }
}
