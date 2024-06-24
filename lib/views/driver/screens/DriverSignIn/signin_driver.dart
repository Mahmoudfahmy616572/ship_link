import 'package:flutter/material.dart';
import 'package:ship_link/views/driver/screens/DriverSignIn/Components/body.dart';

class SignInDriver extends StatefulWidget {
  const SignInDriver({super.key});
  static String routName = '/SignInDriver';
  @override
  State<SignInDriver> createState() => _SignInDriverState();
}

class _SignInDriverState extends State<SignInDriver> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Color(0xFFEBEBEB), body:Body() );
  }
}
