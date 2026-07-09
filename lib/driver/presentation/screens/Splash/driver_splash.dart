import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/constant.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/driver/presentation/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/driver/presentation/screens/DriverSignIn/signin_driver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/utils/sizer.dart';

class DriverSplash extends StatefulWidget {
  const DriverSplash({super.key});
  static String routName = '/DriverSplash';

  @override
  State<DriverSplash> createState() => _DriverSplashState();
}

class _DriverSplashState extends State<DriverSplash> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        token = session.user.id;
        Navigator.of(context).pushReplacementNamed(MainScreenDriver.routName);
        return;
      }
    } catch (_) {
      // Supabase not initialized yet — try again after a short wait
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          token = session.user.id;
          Navigator.of(context).pushReplacementNamed(MainScreenDriver.routName);
          return;
        }
      } catch (_) {
        // Still not ready, go to sign in
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(SignInDriver.routName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10B981),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logos/driver_logo.webp',
              width: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            Text(context.t.tr('ship_link_driver_splash'),
                style: TextStyle(
                    fontSize: 24.sp, fontWeight: FontWeight.w700,
                    color: Colors.white)),
            SizedBox(height: 32.h),
            SizedBox(
              width: 28.w, height: 28.h,
              child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}