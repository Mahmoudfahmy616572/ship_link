import 'package:flutter/material.dart';

import 'notofication_box_msg.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        NotificationBoxMsg(),
        NotificationBoxMsg(),
        NotificationBoxMsg(),
      ],
    );
  }
}
