import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/addPaymentMethod/add_payment_method.dart';

import '../../../../shared/app_style.dart';
import 'card_container.dart';

class Body extends StatefulWidget {
  const Body({
    super.key,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final List<String> cardImage = const [
    "assets/icons/creditcard.svg",
    "assets/icons/paypal.svg",
  ];

  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D7D7),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, AddPaymentMethod.routName);
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD7D7D7),
        // centerTitle: true,
        title: Text(
          "Payment Method",
          style: appStyle(18, FontWeight.w700, Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: cardImage.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  activeIndex = index;
                  setState(() {});
                },
                child: CardItem(
                  image: cardImage[index],
                  isActive: activeIndex == index,
                ),
              );
            }),
      ),
    );
  }
}
