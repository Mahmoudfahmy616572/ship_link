import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/user/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});
  static String routName = '/security';

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.t.tr('security'),
          style: appStyle(22, FontWeight.w700, AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            Text(
              context.t.tr('security_settings'),
              style: appStyle(18, FontWeight.w700, AppColors.textPrimary),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    _securityTile(context, context.t.tr('two_factor_auth'), Icons.security_outlined, AppColors.cta, () {
                      CustomSnackBar.info(context.t.tr('share_feature_coming_soon'), context);
                    }),
                    _divider(context),
                    _securityTile(context, context.t.tr('change_password'), Icons.lock_outline, AppColors.primary, () {
                      Navigator.pushNamed(context, ResetPasswordScreen.routName);
                    }),
                    _divider(context),
                    _securityTile(context, context.t.tr('active_sessions'), Icons.devices_outlined, AppColors.success, () {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user == null) return;
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(context.t.tr('active_sessions')),
                          content: Text('Signed in as:\n${user.email}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              context.t.tr('security_tips'),
              style: appStyle(14, FontWeight.w600, AppColors.textPrimary),
            ),
            SizedBox(height: 12.h),
            _tipTile(Icons.check_circle_outline, context.t.tr('tip_strong_password')),
            SizedBox(height: 8.h),
            _tipTile(Icons.check_circle_outline, context.t.tr('tip_enable_2fa')),
            SizedBox(height: 8.h),
            _tipTile(Icons.check_circle_outline, context.t.tr('tip_review_sessions')),
          ],
        ),
      ),
    );
  }

  Widget _securityTile(BuildContext context, String label, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22.r, color: iconColor),
      title: Text(label, style: appStyle(15, FontWeight.w500, AppColors.textPrimary)),
      trailing: Icon(Icons.chevron_right, size: 22.r, color: AppColors.textHint),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 54.w),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }

  Widget _tipTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.success),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(text, style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
        ),
      ],
    );
  }
}