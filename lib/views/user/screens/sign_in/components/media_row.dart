import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';

import 'media_container.dart';

class MediaRow extends StatelessWidget {
  const MediaRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.0.w),
      child: Center(
        child: MediaContainer(
          img: "assets/icons/googel icon.svg",
        ),
      ),
    );
  }
}
