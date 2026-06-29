import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';

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
          padding: EdgeInsets.all(8.w),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.56,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.r),
                    topLeft: Radius.circular(30.r),
                    bottomLeft: Radius.circular(30.r),
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
