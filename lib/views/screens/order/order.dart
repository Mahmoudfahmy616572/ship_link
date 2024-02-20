import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/delivered/delivered.dart';

class Order extends StatefulWidget {
  const Order({super.key});
  static String routName = '/order';
  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final int _currentIndex = 0;

  final List<Widget> _tabs = [
    const Delivered(),
    const Delivered(),
    const Delivered(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFCDCDCD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFCDCDCD),
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            dividerColor: Colors.transparent,
            labelStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            automaticIndicatorColorAdjustment: true,
            onTap: (int index) {
              setState(() {
                _currentIndex == index ? Colors.black : Colors.white;
              });
            },
            tabs: const [
              Tab(text: 'Deliverd'),
              Tab(text: 'Processing'),
              Tab(text: 'Canceled'),
            ],
          ),
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    ));
  }
}
