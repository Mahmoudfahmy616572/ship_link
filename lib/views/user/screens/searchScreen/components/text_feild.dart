import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          hintText: "Search",
          hintStyle: const TextStyle(color: Color(0xFFCDCDCD)),
          suffixIcon: const Icon(Icons.search_outlined),
          suffixIconColor: const Color(0xFFCDCDCD),
          contentPadding: const EdgeInsets.all(10),
          border: InputBorder.none,
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Colors.transparent, width: 2.0),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(5)),
          fillColor: const Color(0xFF151516).withOpacity(0.8)),
    );
  }
}
