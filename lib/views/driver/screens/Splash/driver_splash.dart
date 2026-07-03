import 'package:flutter/material.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/driver/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/views/driver/screens/DriverSignIn/signin_driver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/utils/sizer.dart';

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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      token = session.user.id;
      Navigator.of(context).pushReplacementNamed(MainScreenDriver.routName);
    } else {
      Navigator.of(context).pushReplacementNamed(SignInDriver.routName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logos/driver_logo.png',
              width: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            Text(context.t.tr('ship_link_driver_splash'),
                style: TextStyle(
                    fontSize: 24.sp, fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
            SizedBox(height: 32.h),
            SizedBox(
              width: 28.w, height: 28.h,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}