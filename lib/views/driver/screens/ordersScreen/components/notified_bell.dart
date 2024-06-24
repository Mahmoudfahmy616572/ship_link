import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class NotifiedBell extends StatelessWidget {
  const NotifiedBell({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(
          color: Color(0xFF303030),
          Ionicons.notifications_outline,
          size: 30,
        ),
        Positioned(
            right: MediaQuery.of(context).size.width * 0.01,
            top: MediaQuery.of(context).size.height * 0.001,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.red),
            ))
      ],
    );
  }
}
