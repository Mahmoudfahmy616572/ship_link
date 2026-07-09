import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';
import 'package:ship_link/web/presentation/layout/web_scaffold.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashWeb extends StatefulWidget {
  const SplashWeb({super.key});
  static String routName = '/splash';

  @override
  State<SplashWeb> createState() => _SplashWebState();
}

class _SplashWebState extends State<SplashWeb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _glow;
  late Animation<double> _progress;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));

    _logoScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.05, 0.7, curve: Curves.easeInOut)),
    );
    _progress = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.9, curve: Curves.easeInOut)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.95, curve: Curves.easeIn)),
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
        Navigator.pushReplacementNamed(context, WebScaffold.routName);
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, WelcomeWeb.routName);
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
                        width: 120 + _glow.value * 60,
                        height: 120 + _glow.value * 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF97316).withValues(alpha: (1 - _glow.value) * 0.2),
                        ),
                      ),
                      Image.asset('assets/logos/user_logo.webp', width: 120, fit: BoxFit.contain),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  context.t.tr('app_name'),
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                SizedBox(height: 48),
                SizedBox(
                  width: 180, height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
                        Positioned(
                          left: (_progress.value + 1) / 2 * 176, top: 0,
                          child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Opacity(
                  opacity: _textFade.value,
                  child: Text(context.t.tr('connecting_deliveries'), style: TextStyle(fontSize: 14, color: Colors.white70)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
