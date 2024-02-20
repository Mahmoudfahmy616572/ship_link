import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'components/body.dart';

class AddShippingAddress extends StatefulWidget {
  const AddShippingAddress({super.key});
  static String routName = '/addShippingAddress';

  @override
  State<AddShippingAddress> createState() => _AddShippingAddressState();
}

class _AddShippingAddressState extends State<AddShippingAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
          backgroundColor: const Color(0xFFCDCDCD),
          centerTitle: true,
          title: Text(
            "Add shipping address",
            style: appStyle(18, FontWeight.w700, Colors.black),
          )),
      body: const Body(),
    );
  }
}
