import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/users/widgets/user_form_dialog.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';

// شاشة تفاصيل اليوزر (بياناته الأساسية)
class AdminUserDetailWeb extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onBack;
  final void Function(Map<String, dynamic> user)? onEdit;
  const AdminUserDetailWeb({super.key, required this.user, this.onBack, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isDark = AdminThemeMode.isDark.value;
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final name = user['name']?.toString() ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final email = user['email']?.toString() ?? '—';
    final phone = user['phone_number']?.toString() ?? '—';
    final role = user['role']?.toString() ?? 'user';
    final joined = user['created_at']?.toString().substring(0, 10) ?? '—';

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack, color: textPrimary),
              SizedBox(width: 8.w),
              Text('${t.tr('user_details')} #${user['id'].toString().substring(0, 8)}',
                  style: appStyle(20, FontWeight.w700, textPrimary)),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                _Row(t.tr('name'), name.isEmpty ? '—' : name, textPrimary, textSecondary),
                _Row(t.tr('email'), email, textPrimary, textSecondary),
                _Row(t.tr('phone_number'), phone, textPrimary, textSecondary),
                _Row(t.tr('role'), role, textPrimary, textSecondary),
                _Row(t.tr('joined'), joined, textPrimary, textSecondary),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (onEdit != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) => UserCreateEditDialog(user: user),
                  );
                  if (result != null && context.mounted) {
                    context.read<AdminUsersCubit>().updateUser(id: user['id'].toString(), data: result);
                    onEdit?.call(user);
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(t.tr('edit_user')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _Row(String label, String value, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: appStyle(13, FontWeight.w400, textSecondary))),
          Expanded(flex: 3, child: Text(value, style: appStyle(15, FontWeight.w600, textPrimary))),
        ],
      ),
    );
  }
}
