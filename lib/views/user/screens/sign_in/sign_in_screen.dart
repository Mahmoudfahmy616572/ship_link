import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/sign_in/components/body.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});
static String routName = '/signIn';
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Color(0xFFEBEBEB), body: Body());
  }
}
