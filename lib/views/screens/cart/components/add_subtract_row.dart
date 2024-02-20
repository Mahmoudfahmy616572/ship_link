import 'package:flutter/material.dart';

import '../../../shared/app_style.dart';
import '../../product/components/add_subtract_btn.dart';

class AddAndSubtractRow extends StatelessWidget {
  const AddAndSubtractRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AddOrSubtractButton(
          ontap: () {},
          icon: Icons.add,
        ),
        const SizedBox(
          width: 7,
        ),
        Text(
          "01",
          style: appStyle(18, FontWeight.w600, Colors.black),
        ),
        const SizedBox(
          width: 7,
        ),
        AddOrSubtractButton(
          ontap: () {},
          icon: Icons.add,
        )
      ],
    );
  }
}
