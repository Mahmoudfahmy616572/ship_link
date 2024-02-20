import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/addPaymentMethod/components/body.dart';
import 'package:ship_link/views/shared/app_style.dart';

class AddPaymentMethod extends StatelessWidget {
  const AddPaymentMethod({super.key});
  static String routName = '/addPaymentMethod';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add payment method",
          style: appStyle(18, FontWeight.w700, Colors.black),
        ),
      ),
      body: const Body(),
    );
  }
}
