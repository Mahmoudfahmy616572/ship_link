import 'package:flutter/material.dart';

class DividerRow extends StatelessWidget {
  const DividerRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
              child: Container(
            height: 0.6,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Colors.white])),
            child: const Divider(
              thickness: 0.6,
              color: Colors.transparent,
            ),
          )),
          const Text(
            "Or continue with",
            style: TextStyle(
              color: Color(0xFFB6B6B6),
            ),
          ),
          Expanded(
              child: Container(
            height: 0.6,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white, Colors.black])),
            child: const Divider(
              thickness: 0.6,
              color: Colors.transparent,
            ),
          )),
        ],
      ),
    );
  }
}
