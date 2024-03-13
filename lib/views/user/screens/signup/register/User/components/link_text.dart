import 'package:flutter/material.dart';

class LinkText extends StatelessWidget {
  const LinkText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        child: const Text(
          "I already have an account!",
          style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Color.fromARGB(255, 143, 165, 183),
              decorationThickness: 2,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ),
    );
  }
}
