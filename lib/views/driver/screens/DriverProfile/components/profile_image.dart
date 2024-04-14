import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage("assets/images/mahmoud.jpg"),
          radius: 60,
        ),
        Positioned(
            bottom: 10,
            right: 0,
            child: InkWell(
              onTap: () {},
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: SvgPicture.asset(
                      "assets/icons/cameraIcon.svg"),
                ),
              ),
            ))
      ],
    );
  }
}
