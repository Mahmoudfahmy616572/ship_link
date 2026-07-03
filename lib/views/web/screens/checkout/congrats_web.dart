import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/web/screens/orders/orders_web.dart';
import 'package:ship_link/utils/sizer.dart';

class CongratsWeb extends StatefulWidget {
  final String? userEmail;
  const CongratsWeb({super.key, this.userEmail});
  static String routName = '/congrats';

  @override
  State<CongratsWeb> createState() => _CongratsWebState();
}

class _CongratsWebState extends State<CongratsWeb> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: AppColors.success, size: 56),
                ),
              ),
              SizedBox(height: 24),
              FadeTransition(
                opacity: _animCtrl,
                child: Text(context.t.tr('order_placed_successfully'),
                    style: appStyle(24, FontWeight.w700, const Color(0xFF111827)),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: 12),
              FadeTransition(
                opacity: _animCtrl,
                child: Text(context.t.tr('order_success_message'),
                    style: appStyle(15, FontWeight.w400, const Color(0xFF6B7280)),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: 8),
              FadeTransition(
                opacity: _animCtrl,
                child: Text(widget.userEmail ?? '',
                    style: appStyle(14, FontWeight.w500, AppColors.primary)),
              ),
              SizedBox(height: 32),
              FadeTransition(
                opacity: _animCtrl,
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, OrdersWeb.routName, (_) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(context.t.tr('view_orders'), style: appStyle(16, FontWeight.w600, Colors.white)),
                  ),
                ),
              ),
              SizedBox(height: 12),
              FadeTransition(
                opacity: _animCtrl,
                child: TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                  child: Text(context.t.tr('continue_shopping'),
                      style: appStyle(14, FontWeight.w500, const Color(0xFF6B7280))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
