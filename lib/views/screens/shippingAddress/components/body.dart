import 'package:flutter/material.dart';

import '../../../shared/app_style.dart';
import 'detailes_container.dart';

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      backgroundColor: const Color(0xFFD7D7D7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD7D7D7),
        title: Text(
          "Shipping address",
          style: appStyle(18, FontWeight.w700, Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(left: 60),
            child: Text(""),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
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
                  const DetailesContainer(),
                ],
              ),
            );
          }),
    );
  }
}
