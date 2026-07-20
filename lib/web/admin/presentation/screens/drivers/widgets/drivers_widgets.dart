import 'package:flutter/material.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';

// بادج حالة السائق (عنده عربية ولا لأ، والمنطقة)
class DriverStateBadge extends StatelessWidget {
  final String? state;
  const DriverStateBadge(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final label = state?.isNotEmpty == true ? state! : 'غير محدد';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: appStyle(12, FontWeight.w600, AppColors.cta)),
    );
  }
}

// جدول السائقين (مش معمول ليه actions لسه)
class DriversTable extends StatelessWidget {
  final List<Map<String, dynamic>> drivers;
  final void Function(Map<String, dynamic> driver)? onActivate;
  final void Function(Map<String, dynamic> driver)? onOpen;
  final bool isCompact;
  const DriversTable(this.drivers, {super.key, this.onActivate, this.onOpen, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (isCompact) {
      return Column(
        children: drivers.map((d) {
          final name = d['name']?.toString() ?? '—';
          final hasVehicle = d['vehicle_number']?.toString().isNotEmpty == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AdminThemeMode.surface(AdminThemeMode.isDark.value),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminThemeMode.border(AdminThemeMode.isDark.value)),
            ),
            child: InkWell(
              onTap: () => onOpen?.call(d),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(name, style: appStyle(15, FontWeight.w700, AdminThemeMode.textPrimary(AdminThemeMode.isDark.value)))),
                      DriverStateBadge(d['state']?.toString()),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(d['email']?.toString() ?? '—', style: appStyle(13, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
                  const SizedBox(height: 2),
                  Text('${t.tr('phone_number')}: ${d['phone_number']?.toString() ?? '—'}', style: appStyle(13, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
                  if (hasVehicle && onActivate != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onActivate!.call(d),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(t.tr('activate')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ] else if (!hasVehicle)
                    Text(t.tr('incomplete'), style: appStyle(13, FontWeight.w500, AppColors.textDisabled)),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
    final columns = [t.tr('name'), t.tr('email'), t.tr('phone_number'), t.tr('vehicle_type'), t.tr('state'), t.tr('actions')];
    return Container(
      decoration: BoxDecoration(
        color: AdminThemeMode.surface(AdminThemeMode.isDark.value),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminThemeMode.border(AdminThemeMode.isDark.value)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((c) => DataColumn(label: Text(c, style: appStyle(13, FontWeight.w600, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))))).toList(),
          rows: drivers.map((d) {
            final name = d['name']?.toString() ?? '—';
            final hasVehicle = d['vehicle_number']?.toString().isNotEmpty == true;
            return DataRow(
              onSelectChanged: (_) => onOpen?.call(d),
              cells: [
                DataCell(Text(name, style: appStyle(14, FontWeight.w500, AdminThemeMode.textPrimary(AdminThemeMode.isDark.value)))),
                DataCell(Text(d['email']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)))),
                DataCell(Text(d['phone_number']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)))),
                DataCell(Text(d['vehicle_type']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)))),
                DataCell(DriverStateBadge(d['state']?.toString())),
                DataCell(
                  hasVehicle && onActivate != null
                      ? OutlinedButton.icon(
                          onPressed: () => onActivate!.call(d),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: Text(t.tr('activate')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      : hasVehicle
                          ? const SizedBox.shrink()
                          : Text(t.tr('incomplete'), style: appStyle(13, FontWeight.w500, AppColors.textDisabled)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// صفحة الخطأ
class DriversErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const DriversErrorView(this.message, this.onRetry, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: appStyle(15, FontWeight.w500, AppColors.error)),
        SizedBox(height: 12.h),
        ElevatedButton(onPressed: onRetry, child: Text(t.tr('retry'))),
      ]),
    );
  }
}

// الـ loading بتاع الجدول
class DriversTableShimmer extends StatelessWidget {
  const DriversTableShimmer({super.key});

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
