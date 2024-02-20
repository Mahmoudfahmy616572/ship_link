import 'package:flutter/material.dart';

class ProductTextTitle extends StatelessWidget {
  const ProductTextTitle({
    super.key,
    required this.textStyle,
    required this.text,
  });
  final TextStyle? textStyle;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: textStyle,
          )
        ],
      ),
    );
  }
}

