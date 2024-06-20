import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/ForgotPassword/components/body.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});
  static String routName = '/forgotPassword';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}
