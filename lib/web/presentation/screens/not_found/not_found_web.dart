import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';

class NotFoundWeb extends StatelessWidget {
  const NotFoundWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_outlined, size: 80, color: const Color(0xFFD1D5DB)),
            SizedBox(height: 24),
            Text('404', style: appStyle(64, FontWeight.w700, const Color(0xFFE5E7EB))),
            SizedBox(height: 8),
            Text(context.t.tr('page_not_found'),
                style: appStyle(18, FontWeight.w500, const Color(0xFF6B7280))),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(context.t.tr('go_home')),
            ),
          ],
        ),
      ),
    );
  }
}
