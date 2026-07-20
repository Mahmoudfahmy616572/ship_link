import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';

// شاشة تفاصيل السائق (بياناته الأساسية)
class AdminDriverDetailWeb extends StatelessWidget {
  final Map<String, dynamic> driver;
  final VoidCallback? onBack;
  final void Function(Map<String, dynamic> driver)? onActivate;
  const AdminDriverDetailWeb({super.key, required this.driver, this.onBack, this.onActivate});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isDark = AdminThemeMode.isDark.value;
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final name = driver['name']?.toString() ?? '—';
    final email = driver['email']?.toString() ?? '—';
    final phone = driver['phone_number']?.toString() ?? '—';
    final vehicleType = driver['vehicle_type']?.toString() ?? '—';
    final vehicleNumber = driver['vehicle_number']?.toString() ?? '—';
    final state = driver['state']?.toString() ?? '—';
    final id = driver['id'].toString().substring(0, 8);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack, color: textPrimary),
              SizedBox(width: 8.w),
              Text('${t.tr('driver_details')} #$id',
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
                _Row(t.tr('name'), name, textPrimary, textSecondary),
                _Row(t.tr('email'), email, textPrimary, textSecondary),
                _Row(t.tr('phone_number'), phone, textPrimary, textSecondary),
                _Row(t.tr('vehicle_type'), vehicleType, textPrimary, textSecondary),
                _Row(t.tr('vehicle_number'), vehicleNumber, textPrimary, textSecondary),
                _Row(t.tr('state'), state, textPrimary, textSecondary),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (vehicleNumber.isNotEmpty && onActivate != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // نفعل السائق عن طريق تحديث حالة المركبة
                  context.read<AdminDriversCubit>().updateDriver(
                    id: driver['id'].toString(),
                    fields: {'state': driver['state']?.toString() ?? 'active'},
                  );
                  onBack?.call();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(t.tr('activate')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
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
