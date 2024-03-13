import 'package:flutter/material.dart';

class ButtonDeleteproduct extends StatelessWidget {
  const ButtonDeleteproduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23,
      width: 23,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
          shape: BoxShape.circle,
          color: Colors.transparent),
      child: const Icon(
        Icons.close,
        color: Colors.black,
        size: 20,
      ),
    );
  }
}
