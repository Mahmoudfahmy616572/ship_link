import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        child: Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background_image.jpg"),
                  colorFilter:
                      ColorFilter.mode(Colors.black, BlendMode.softLight),
                  fit: BoxFit.cover)),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            const Color(0xFF343434).withOpacity(0.2),
            const Color(0xFF343434).withOpacity(0.22)
          ])),
          child: const Center(
            child: Text(
              'Fast Shipping at Low\nCosts',
              style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1,
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ));
  }
}
