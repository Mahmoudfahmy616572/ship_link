import 'package:flutter/material.dart';

class LogoAndIconTopScreen extends StatelessWidget {
  const LogoAndIconTopScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              size: 28,
            )),
        Padding(
          padding: const EdgeInsets.only(right: 50, top: 15),
          child: Image.asset(
            "assets/images/signin Logo.png",
            fit: BoxFit.cover,
          ),
        ),
        const Text(""),
      ],
    );
  }
}
