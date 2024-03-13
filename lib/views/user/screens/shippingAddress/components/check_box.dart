import 'package:flutter/material.dart';

class CheckBox extends StatefulWidget {
  const CheckBox({
    super.key,
    required this.isChecked,
  });

  final bool isChecked;

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: Colors.black,
      side: BorderSide(
          color: widget.isChecked
              ? Colors.black
              : const Color.fromARGB(255, 110, 110, 110)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      value: widget.isChecked,
      onChanged: (value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}
