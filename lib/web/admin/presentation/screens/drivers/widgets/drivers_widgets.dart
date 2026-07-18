import 'package:flutter/material.dart';
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
  const DriversTable(this.drivers, {super.key, this.onActivate});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final columns = [t.tr('name'), t.tr('email'), t.tr('phone_number'), t.tr('vehicle_type'), t.tr('state'), t.tr('actions')];
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
          rows: drivers.map((d) {
            final name = d['name']?.toString() ?? '—';
            final hasVehicle = d['vehicle_number']?.toString().isNotEmpty == true;
            return DataRow(cells: [
              DataCell(Text(name, style: appStyle(14, FontWeight.w500, AppColors.textPrimary))),
              DataCell(Text(d['email']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
              DataCell(Text(d['phone_number']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
              DataCell(Text(d['vehicle_type']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
              DataCell(DriverStateBadge(d['state']?.toString())),
              DataCell(
                hasVehicle
                    ? OutlinedButton.icon(
                        onPressed: () => onActivate?.call(d),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(t.tr('activate')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    : Text(t.tr('incomplete'), style: appStyle(13, FontWeight.w500, AppColors.textDisabled)),
              ),
            ]);
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

// سنackbar نجاح التحديث
void showDriverUpdateSnackbar(BuildContext context, String name) {
  final t = context.t;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${t.tr('driver_activated')} : $name'),
      backgroundColor: AppColors.success,
    ),
  );
}
