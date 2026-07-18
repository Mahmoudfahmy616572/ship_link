import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_scaffold.dart';

// صفحة دخول الأدمن، بتتحقق من الإيميل وباسورد وبتشيك على جدول admins
class AdminLoginWeb extends StatelessWidget {
  const AdminLoginWeb({super.key});
  static String routName = '/admin/login';

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final t = context.t;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            width: 420,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(color: AppColors.cardShadowMedium, blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Form(
              key: formKey,
              child: BlocConsumer<AdminAuthCubit, dynamic>(
                listener: (context, state) {
                  if (state is AdminAuthSuccess || state is AdminAuthRestored) {
                    Navigator.pushReplacementNamed(context, AdminScaffoldWeb.routName);
                  } else if (state is AdminAuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                    );
                  }
                },
                builder: (context, state) {
                  final loading = state is AdminAuthLoading;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // أيقونة اللوحة
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                      ),
                      SizedBox(height: 20.h),
                      Text('ShipLink Admin',
                          style: appStyle(24, FontWeight.w700, AppColors.textPrimary)),
                      SizedBox(height: 4.h),
                      Text(t.tr('admin_login_subtitle'),
                          style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
                      SizedBox(height: 28.h),
                      // حقل الإيميل
                      TextFormField(
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          labelText: t.tr('email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? t.tr('email_required') : null,
                      ),
                      SizedBox(height: 16.h),
                      // حقل الباسورد
                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: t.tr('password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? t.tr('password_required') : null,
                        onFieldSubmitted: (_) => _submit(formKey, context, emailCtrl, passCtrl),
                      ),
                      SizedBox(height: 24.h),
                      // زر الدخول
                      ElevatedButton(
                        onPressed: loading ? null : () => _submit(formKey, context, emailCtrl, passCtrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: loading
                            ? const SizedBox(height: 18, width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(t.tr('sign_in'), style: appStyle(15, FontWeight.w600, Colors.white)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // نعمل التحقق من الفورم وبعدين نستدعي الكيوبت
  void _submit(GlobalKey<FormState> formKey, BuildContext context,
      TextEditingController email, TextEditingController pass) {
    if (formKey.currentState!.validate()) {
      context.read<AdminAuthCubit>().signIn(email: email.text.trim(), password: pass.text);
    }
  }
}
