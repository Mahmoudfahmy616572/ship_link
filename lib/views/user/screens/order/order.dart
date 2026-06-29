import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/user/screens/delivered/delivered.dart';

class Order extends StatefulWidget {
  const Order({super.key});
  static String routName = '/order';
  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDCDCD),
        bottom: TabBar(
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          dividerColor: Colors.transparent,
          labelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
          automaticIndicatorColorAdjustment: true,
          tabs: [
            Tab(text: context.t.tr('deliverd')),
            Tab(text: context.t.tr('processing')),
            Tab(text: context.t.tr('canceled')),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          Delivered(statusFilter: 'delivered'),
          Delivered(statusFilter: 'pending'),
          Delivered(statusFilter: 'cancelled'),
        ],
      ),
    );
  }
}