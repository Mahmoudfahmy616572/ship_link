import 'package:flutter/material.dart';

import 'media_container.dart';

class MediaRow extends StatelessWidget {
  const MediaRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MediaContainer(
            img: "assets/icons/googel icon.svg",
          ),
          MediaContainer(
            img: "assets/icons/apple icon.svg",
          ),
          MediaContainer(
            img: "assets/icons/facebook icon.svg",
          ),
        ],
      ),
    );
  }
}
