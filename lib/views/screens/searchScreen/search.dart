import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'components/TextField.dart';
import 'components/space.dart';

class Search extends StatelessWidget {
  const Search({super.key});
  static String routName = '/Search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDCDCD),
        title: Text(
          "Home",
          style: appStyle(18, FontWeight.w600, Colors.black),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const BuildTextField(),
          const Space(),
          Text(
            "Recent searches",
            style: appStyle(18, FontWeight.bold, Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset("assets/images/clock.png"),
              const SizedBox(
                width: 5,
              ),
              Text(
                'Mobile',
                style: appStyle(14, FontWeight.normal, const Color(0xFF606060)),
              )
            ],
          ),
          const Space(),
          Text(
            'Categories :',
            style: appStyle(16, FontWeight.w700, Colors.black),
          ),
          const Space(),
          Row(
            children: [
              const ImageProduct(),
              const SizedBox(
                width: 10,
              ),
              Text(
                "mobile",
                style: appStyle(14, FontWeight.normal, const Color(0xFF606060)),
              )
            ],
          )
        ]),
      ),
    );
  }
}

class ImageProduct extends StatelessWidget {
  const ImageProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
                image: AssetImage("assets/images/category1.png"))));
  }
}
