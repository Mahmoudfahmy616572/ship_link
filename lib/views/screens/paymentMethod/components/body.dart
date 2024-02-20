import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/addPaymentMethod/add_payment_method.dart';

import '../../../shared/app_style.dart';
import 'master_card_container.dart';
import 'visa_container.dart';

class Body extends StatefulWidget {
  const Body({
    super.key,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isChecked = false;
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
        centerTitle: true,
        title: Text(
          "Payment Method",
          style: appStyle(18, FontWeight.w700, Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const MasterCardContainer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Checkbox(
                    activeColor: Colors.black,
                    side: BorderSide(
                        color: isChecked
                            ? Colors.black
                            : const Color.fromARGB(255, 110, 110, 110)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Text(
                    "Use as the shipping address",
                    style: isChecked
                        ? appStyle(17, FontWeight.w400, Colors.black)
                        : appStyle(17, FontWeight.w400, Colors.grey),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const VisaContainer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Checkbox(
                    activeColor: Colors.black,
                    side: BorderSide(
                        color: isChecked
                            ? Colors.black
                            : const Color.fromARGB(255, 110, 110, 110)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Text(
                    "Use as default payment method",
                    style: isChecked
                        ? appStyle(17, FontWeight.w400, Colors.black)
                        : appStyle(17, FontWeight.w400, Colors.grey),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
