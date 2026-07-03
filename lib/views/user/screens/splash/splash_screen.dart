import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/welcome/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/utils/sizer.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  static String routName = '/splashScreen';
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.95, curve: Curves.easeInOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    Timer(const Duration(milliseconds: 2800), _checkAuth);
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.pushReplacementNamed(context, MainScreen.routName);
    } else {
      Navigator.pushReplacementNamed(context, WelcomeScreen.routName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _logoAnimation.value,
                  child: Transform.scale(
                    scale: 0.8 + _logoAnimation.value * 0.2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120.w + _glowAnimation.value * 60.w,
                          height: 120.w + _glowAnimation.value * 60.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF97316).withOpacity(
                              (1 - _glowAnimation.value) * 0.2,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/logos/user_logo.png',
                          width: 120.w,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Opacity(
                  opacity: _logoAnimation.value,
                  child: Text(
                    context.t.tr('app_name'),
                    style: GoogleFonts.inter(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                SizedBox(height: 48.h),
                SizedBox(
                  width: 180.w,
                  height: 4.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Positioned(
                          left: (_progressAnimation.value + 1) / 2 * 176,
                          top: 0,
                          child: Container(
                            width: 4.w,
                            height: 4.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF97316),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Opacity(
                  opacity: _textAnimation.value,
                  child: Text(
                    context.t.tr('connecting_deliveries'),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
