import 'package:flutter/material.dart';
import '../../../constant/colors.dart';
import '../../shared/app_style.dart';
import 'package:ship_link/utils/sizer.dart';

class AdminStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AdminStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: appStyle(14, FontWeight.normal, AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Text(value,
                    style: appStyle(24, FontWeight.bold, Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}