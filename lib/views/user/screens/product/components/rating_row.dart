import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class RaitingRow extends StatelessWidget {
  const RaitingRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 30,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          "4.5",
          style: appStyle(18, FontWeight.w700, Colors.black),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          "(50 reviews)",
          style: appStyle(16, FontWeight.normal, Colors.grey),
        )
      ],
    );
  }
}
