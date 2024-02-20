import 'package:flutter/material.dart';

class RowCardData extends StatelessWidget {
  const RowCardData({
    super.key,
    required this.name,
    required this.date,
    required this.textStyle1,
    required this.textStyle2,
  });
  final String name;
  final String date;
  final TextStyle? textStyle1;
  final TextStyle? textStyle2;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: textStyle1),
          Text(date, style: textStyle2)
        ],
      ),
    );
  }
}
