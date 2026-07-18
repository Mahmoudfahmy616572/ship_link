import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_cubit.dart';

// البادج بتاع نوع المستخدم (user / driver / admin)
class UserRoleBadge extends StatelessWidget {
  final String role;
  const UserRoleBadge(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin' || role == 'driver';
    final color = role == 'driver' ? AppColors.cta : (isAdmin ? AppColors.primary : AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(role, style: appStyle(12, FontWeight.w600, color)),
    );
  }
}

// جدول المستخدمين
class UsersTable extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final void Function(Map<String, dynamic> user)? onOpen;
  const UsersTable(this.users, {super.key, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final columns = [t.tr('name'), t.tr('email'), t.tr('phone_number'), t.tr('role'), t.tr('joined')];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((c) => DataColumn(label: Text(c, style: appStyle(13, FontWeight.w600, AppColors.textSecondary)))).toList(),
          rows: users.map((u) {
            final name = u['name']?.toString() ?? '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
            final joined = u['created_at']?.toString().substring(0, 10) ?? '—';
            return DataRow(
              onSelectChanged: (_) => onOpen?.call(u),
              cells: [
                DataCell(Text(name.isEmpty ? '—' : name, style: appStyle(14, FontWeight.w500, AppColors.textPrimary))),
                DataCell(Text(u['email']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
                DataCell(Text(u['phone_number']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
                DataCell(UserRoleBadge(u['role']?.toString() ?? 'user')),
                DataCell(Text(joined, style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// صفحة الخطأ مع زر إعادة المحاولة
class UsersErrorView extends StatelessWidget {
  final String message;
  const UsersErrorView(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: appStyle(15, FontWeight.w500, AppColors.error)),
        SizedBox(height: 12.h),
        ElevatedButton(onPressed: () => context.read<AdminUsersCubit>().loadUsers(), child: Text(t.tr('retry'))),
      ]),
    );
  }
}

// الـ loading بتاع الجدول
class UsersTableShimmer extends StatelessWidget {
  const UsersTableShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(height: 64, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
