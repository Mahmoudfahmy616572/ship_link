import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/utils/sizer.dart';

class LinkText extends StatelessWidget {
  const LinkText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        child: Text(
          context.t.tr('i_already_have_account'),
          style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Color.fromARGB(255, 143, 165, 183),
              decorationThickness: 2,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ),
    );
  }
}
