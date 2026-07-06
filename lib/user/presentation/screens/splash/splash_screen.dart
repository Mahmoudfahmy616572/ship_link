import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/user/presentation/screens/MainScreen/main_screen.dart';
import 'package:ship_link/user/presentation/screens/welcome/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  static String routName = '/splashScreen';
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
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

    // Logo starts visible at full size (matches native splash) then pulses
    _logoScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.7, curve: Curves.easeInOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.95, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _checkAuth();
    });
    _controller.forward();
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacementNamed(context, MainScreen.routName);
        return;
      }
    } catch (_) {
      // Supabase not initialized yet
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, WelcomeScreen.routName);
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
      backgroundColor: const Color(0xFFF97316),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                    scale: _logoScale.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120.w + _glowAnimation.value * 60.w,
                          height: 120.w + _glowAnimation.value * 60.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF97316).withValues(
                              alpha: (1 - _glowAnimation.value) * 0.2,
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
                  SizedBox(height: 24.h),
                Text(
                  context.t.tr('app_name'),
                  style: GoogleFonts.inter(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                      color: Colors.white70,
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
