import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/sign_in/sign_in_screen.dart';

import 'components/body.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  static String routName = '/splashScreen';
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4),
        () => Navigator.pushReplacementNamed(context, SignIn.routName));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}
