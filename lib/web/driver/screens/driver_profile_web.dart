import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/driver/data/repositories/driver_earnings_repository_impl.dart';
import 'package:ship_link/web/driver/cubits/get_userdriver_data/get_userdriver_data_web_cubit.dart';

class DriverProfileWeb extends StatelessWidget {
  const DriverProfileWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: BlocBuilder<GetUserdriverDataWebCubit, GetUserdriverDataWebState>(
            builder: (context, state) {
              if (state is GetUserdriverDataLoading) return const Center(child: CircularProgressIndicator());
              if (state is GetUserdriverDataError) return Center(child: Text(state.message));
              if (state is GetUserdriverDataSuccess) {
                final data = state.userData.data;
                final driverId = Supabase.instance.client.auth.currentUser?.id ?? '';
                return isWide ? _buildWideLayout(context, data, driverId) : _buildNarrowLayout(context, data, driverId);
              }
              return const Center(child: Text('Something went wrong'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, dynamic data, String driverId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildProfileCard(context, data, driverId)),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildMenuSection(context)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, dynamic data, String driverId) {
    return Column(
      children: [
        _buildProfileCard(context, data, driverId),
        const SizedBox(height: 16),
        _buildMenuSection(context),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic data, String driverId) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                (data?.name ?? 'D')[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(data?.name ?? 'Driver', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(data?.email ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              _avgRatingWidget(driverId),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(6)),
                child: Text(data?.vehicleType ?? 'Bike', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildEarningsStats(driverId),
        ],
      ),
    );
  }

  Widget _avgRatingWidget(String driverId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getDriverRating(driverId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(width: 40, height: 14);
        final avg = snapshot.data!['avg'] as double;
        return Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B)));
      },
    );
  }

  Widget _buildEarningsStats(String driverId) {
    return Row(
      children: [
        _tripsStatItem(driverId),
        _ratingStatItem(driverId),
        _earningsStatItem(driverId),
      ],
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

  Widget _earningsStatItem(String driverId) {
    return FutureBuilder<double>(
      future: DriverEarningsRepositoryImpl().getWeekEarnings(driverId).then((r) => r.fold((_) => 0.0, (v) => v)),
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
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _menuItem(Icons.person_outline, 'Personal Info', 'Name, phone, email', () => _editDialog(context)),
          _menuItem(Icons.time_to_leave_outlined, 'Vehicle Info', 'Vehicle type & number', () {}),
          _menuItem(Icons.payment_outlined, 'Payment', 'Bank account & earnings', () {}),
          _menuItem(Icons.settings_outlined, 'Settings', 'App preferences', () {}),
          _menuItem(Icons.headset_mic_outlined, 'Help & Support', 'Contact us & FAQ', () {}),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/driver/signin');
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Log Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }

  Future<Map<String, dynamic>> _getDriverRating(String driverId) async {
    try {
      final data = await Supabase.instance.client.from('driver_ratings').select('rating').eq('driver_id', driverId);
      if (data.isEmpty) return {'avg': 0.0, 'count': 0};
      double sum = 0;
      for (final row in data) { sum += (row['rating'] as num).toDouble(); }
      return {'avg': sum / data.length, 'count': data.length};
    } catch (_) {
      return {'avg': 0.0, 'count': 0};
    }
  }

  Future<int> _getTripsCount(String driverId) async {
    try {
      final data = await Supabase.instance.client.from('orders').select('id').eq('driver_id', driverId).eq('status', 'delivered');
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  void _editDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
