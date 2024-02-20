import 'package:flutter/material.dart';

class BuildCategoryContainer extends StatelessWidget {
  const BuildCategoryContainer({
    super.key,
    required this.img,
  });
  final String img;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SizedBox(
        width: 65,
        height: 65,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image(
            image: AssetImage(img),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
