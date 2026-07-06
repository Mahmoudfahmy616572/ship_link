import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/core/utils/sizer.dart';

class AdminDrivers extends StatefulWidget {
  const AdminDrivers({super.key});
  static String routName = '/admin/drivers';

  @override
  State<AdminDrivers> createState() => _AdminDriversState();
}

class _AdminDriversState extends State<AdminDrivers> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _drivers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    final drivers = await _supabase.getProfilesByRole('driver');
    setState(() {
      _drivers = drivers;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ShimmerLoading.list();
    }

    if (_drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text('No Drivers', style: appStyle(20, FontWeight.bold, AppColors.textPrimary)),
            SizedBox(height: 8.h),
            Text('No driver accounts registered yet',
                style: appStyle(14, FontWeight.normal, AppColors.textHint)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _drivers.length,
      itemBuilder: (_, i) {
        final d = _drivers[i];
        final name = d['name'] ?? d['first_name'] ?? 'Unknown';
        final email = d['email'] ?? '';
        final phone = d['phone_number'] ?? '';
        final vehicle = d['vehicle_number'] ?? '';
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withAlpha(25),
                  child: Text(
                    (name is String && name.isNotEmpty ? name[0] : '?').toUpperCase(),
                    style: appStyle(20, FontWeight.w700, AppColors.primary),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.toString(), style: appStyle(16, FontWeight.w600, AppColors.textPrimary)),
                      SizedBox(height: 4.h),
                      if (email.isNotEmpty)
                        Text(email, style: appStyle(12, FontWeight.w400, AppColors.textHint)),
                      if (phone.isNotEmpty)
                        Text(phone, style: appStyle(12, FontWeight.w400, AppColors.textHint)),
                      if (vehicle.isNotEmpty)
                        Text('Vehicle: $vehicle', style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('Active', style: appStyle(12, FontWeight.w600, AppColors.success)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}