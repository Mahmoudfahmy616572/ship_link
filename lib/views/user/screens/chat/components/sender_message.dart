import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class SenderMessage extends StatelessWidget {
  const SenderMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.56,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(0))),
            child: Text(
              "Hello i'm here mother fucker ddjjdj djdjsadsjfaj dajfajdsfja adjf",
              style: appStyle(16, FontWeight.normal, Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
