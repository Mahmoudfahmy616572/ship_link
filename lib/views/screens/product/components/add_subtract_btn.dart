import 'package:flutter/material.dart';

class AddOrSubtractButton extends StatelessWidget {
  const AddOrSubtractButton({
    super.key,
    required this.ontap,
    required this.icon,
  });
  final void Function()? ontap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(55),
      onTap: ontap,
      child: Container(
        width: 30,
        height: 30,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
        child: Icon(icon),
      ),
    );
  }
}
