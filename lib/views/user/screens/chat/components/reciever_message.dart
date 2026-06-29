import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';

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
          padding: EdgeInsets.all(8.w),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.r),
                    topLeft: Radius.circular(30.r),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(30.r))),
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
