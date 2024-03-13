
import 'package:flutter/material.dart';

import '../../../../../../shared/app_style.dart';

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: appStyle(15, FontWeight.normal, const Color(0xFF6C6C6C)),
    );
  }
}
