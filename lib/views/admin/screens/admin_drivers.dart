import 'package:flutter/material.dart';
import '../../shared/app_style.dart';

class AdminDrivers extends StatelessWidget {
  const AdminDrivers({super.key});
  static String routName = '/admin/drivers';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Driver Management',
              style: appStyle(20, FontWeight.bold, Colors.grey)),
          const SizedBox(height: 8),
          Text('Coming soon - manage drivers, view live locations',
              style: appStyle(14, FontWeight.normal, Colors.grey)),
        ],
      ),
    );
  }
}
