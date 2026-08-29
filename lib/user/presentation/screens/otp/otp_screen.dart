import 'package:flutter/material.dart';
import 'package:ship_link/user/presentation/screens/otp/components/body.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.email});
  final String email;
  static String routName = '/otpScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(email: email),
    );
  }
}
