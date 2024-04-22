import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class RecieverMessage extends StatelessWidget {
  const RecieverMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(30))),
            child: Text(
              "Hello i'm here mother fucker",
              style: appStyle(16, FontWeight.normal, Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
