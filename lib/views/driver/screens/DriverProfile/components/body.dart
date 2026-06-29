import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/data/services/driverEarnings/driver_earnings_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubitDriver/get_user_driver_data/get_userdriver_data_cubit.dart';
import 'package:ship_link/views/driver/screens/DriverSignIn/signin_driver.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';
import 'package:ship_link/views/driver/screens/DriverProfile/components/driver_charts_section.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/shared/text_field.dart';
import 'package:ship_link/views/shared/settings_screen.dart';
import 'package:ship_link/cubitDriver/upDateUserData/up_date_user_data_cubit.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/utils/sizer.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetUserdriverDataCubit, GetUserdriverDataState>(
      builder: (context, state) {
        if (state is GetUserdriverDataLoading) {
          return ShimmerLoading.list();
        } else if (state is GetUserdriverDataFailure) {
          return Center(child: CustomErrorWidget(errMessage: state.errMessage));
        } else if (state is GetUserdriverDataSuccess) {
          final data = state.getuserDriverData.data;
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, data?.name ?? 'Driver', data?.email ?? ''),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 80.h),
                      children: [
                        SizedBox(height: 64.h),
                        _buildStatsRow(data),
                        SizedBox(height: 24.h),
                        const DriverChartsSection(),
                        SizedBox(height: 24.h),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Info',
                          subtitle: 'Name, phone, email',
                          onTap: () => _editDialog(context, data?.name ?? '', data?.phoneNumber ?? ''),
                        ),
                        _buildMenuItem(
                          icon: Icons.time_to_leave_outlined,
                          title: 'Vehicle Info',
                          subtitle: 'Vehicle type, number',
                          onTap: () => _showVehicleInfo(context, data),
                        ),
                        _buildMenuItem(
                          icon: Icons.payment_outlined,
                          title: 'Payment',
                          subtitle: 'Bank account, earnings',
                          onTap: () => _showPaymentInfo(context, data),
                        ),
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          subtitle: 'App preferences',
                          onTap: () => Navigator.pushNamed(context, SettingsScreen.routName),
                        ),
                        _buildMenuItem(
                          icon: Icons.headset_mic_outlined,
                          title: 'Help & Support',
                          subtitle: 'Contact us, FAQ',
                        ),
                        SizedBox(height: 24.h),
                        _buildLogoutButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Profile',
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.logout, size: 20, color: Color(0xFFEF4444)),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildStatsRow(dynamic data) {
    final driverId = Supabase.instance.client.auth.currentUser?.id ?? '';
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.w, height: 60.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text('JD',
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data?.name ?? 'Driver',
                        style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                        SizedBox(width: 4.w),
                        _avgRatingWidget(driverId),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(data?.vehicleType ?? 'Bike',
                              style: appStyle(12, FontWeight.w500, const Color(0xFF6B7280))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const Divider(height: 1),
          SizedBox(height: 16.h),
          Row(
            children: [
              _tripsStatItem(driverId),
              _ratingStatItem(driverId),
              _earningsStatItem(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avgRatingWidget(String driverId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getDriverRating(driverId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox(width: 40.w, height: 14.h);
        final avg = snapshot.data!['avg'] as double;
        return Text(avg.toStringAsFixed(1),
            style: appStyle(14, FontWeight.w600, const Color(0xFFF59E0B)));
      },
    );
  }

  Widget _tripsStatItem(String driverId) {
    return FutureBuilder<int>(
      future: _getTripsCount(driverId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return _statItem(Icons.delivery_dining, '$count', 'Trips');
      },
    );
  }

  Widget _ratingStatItem(String driverId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getDriverRating(driverId),
      builder: (context, snapshot) {
        final avg = snapshot.data?['avg'] as double? ?? 0;
        final cnt = snapshot.data?['count'] as int? ?? 0;
        return _statItem(Icons.star, '${avg.toStringAsFixed(1)} ($cnt)', 'Rating');
      },
    );
  }

  Widget _earningsStatItem() {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) {
      return _statItem(Icons.attach_money, '\$0', 'Week');
    }
    return FutureBuilder<double>(
      future: DriverEarningsService(Supabase.instance.client).getWeekEarnings(driverId),
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        return _statItem(Icons.attach_money, '\$${value.toStringAsFixed(0)}', 'Week');
      },
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          SizedBox(height: 4.h),
          Text(value,
              style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
          Text(label,
              style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40.w, height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
        subtitle: Text(subtitle,
            style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Future<Map<String, dynamic>> _getDriverRating(String driverId) async {
    try {
      final data = await Supabase.instance.client
          .from('driver_ratings')
          .select('rating')
          .eq('driver_id', driverId);
      if (data.isEmpty) return {'avg': 0.0, 'count': 0};
      double sum = 0;
      for (final row in data) {
        sum += (row['rating'] as num).toDouble();
      }
      return {'avg': sum / data.length, 'count': data.length};
    } catch (_) {
      return {'avg': 0.0, 'count': 0};
    }
  }

  Future<int> _getTripsCount(String driverId) async {
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select('id')
          .eq('driver_id', driverId)
          .eq('status', 'delivered');
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, double>> _getAllEarnings(String driverId) async {
    final svc = DriverEarningsService(Supabase.instance.client);
    try {
      final results = await Future.wait([
        svc.getTodayEarnings(driverId),
        svc.getWeekEarnings(driverId),
        svc.getAllTimeEarnings(driverId),
      ]);
      return {'today': results[0], 'week': results[1], 'all': results[2]};
    } catch (_) {
      return {'today': 0, 'week': 0, 'all': 0};
    }
  }

  void _showVehicleInfo(BuildContext context, dynamic data) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Info',
                style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
            SizedBox(height: 20.h),
            _infoRow('Type', data?.vehicleType ?? '—'),
            _infoRow('Number', data?.vehicleNumber ?? '—'),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentInfo(BuildContext context, dynamic data) {
    final driverId = Supabase.instance.client.auth.currentUser?.id ?? '';
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.w),
        child: FutureBuilder<Map<String, double>>(
          future: _getAllEarnings(driverId),
          builder: (context, snapshot) {
            final today = snapshot.data?['today'] ?? 0;
            final week = snapshot.data?['week'] ?? 0;
            final all = snapshot.data?['all'] ?? 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment',
                    style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
                SizedBox(height: 20.h),
                _infoRow('Today', '\$${today.toStringAsFixed(0)}'),
                _infoRow('This Week', '\$${week.toStringAsFixed(0)}'),
                _infoRow('All Time', '\$${all.toStringAsFixed(0)}'),
                _infoRow('Status', 'Active'),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: appStyle(14, FontWeight.w500, const Color(0xFF6B7280))),
          Text(value, style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthCubit>().signOutDriver();
          CustomSnackBar.displaySuccessMotionToast(
              'Logged out successfully', context);
          Navigator.pushReplacementNamed(context, SignInDriver.routName);
        },
        icon: const Icon(Icons.logout, size: 18),
        label: Text('Log Out',
            style: appStyle(15, FontWeight.w600, const Color(0xFFEF4444))),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  void _editDialog(BuildContext context, String currentName, String currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Edit Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BuildTextField(
              controller: nameCtrl,
              hintText: 'Enter your name',
              obscureText: false,
            ),
            SizedBox(height: 12.h),
            BuildTextField(
              controller: phoneCtrl,
              hintText: 'Enter phone number',
              textInputType: TextInputType.phone,
              obscureText: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<UpDateUserDataCubit>().updateUserData(
                    name: nameCtrl.text,
                    phoneNumber: phoneCtrl.text,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}