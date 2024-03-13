import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardItem extends StatelessWidget {
  const CardItem({super.key, required this.image, required this.isActive});
  final String image;

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 800),
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: isActive ? const Color(0xff34A853) : Colors.white,
                    width: 3),
                borderRadius: BorderRadius.circular(9)),
            shadows: [
              BoxShadow(
                  color: isActive ? const Color(0xff34A853) : Colors.white,
                  offset: const Offset(0, 0),
                  blurRadius: 4,
                  spreadRadius: 0),
            ]),
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 200,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9), color: Colors.white),
          child: SvgPicture.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
