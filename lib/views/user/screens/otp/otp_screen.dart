import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/otp/components/body.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
static String routName = '/otpScreen';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}
