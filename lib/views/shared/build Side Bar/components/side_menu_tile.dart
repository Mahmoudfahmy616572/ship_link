import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/views/user/screens/Home/home_screen.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/Profile/profile.dart';
import 'package:ship_link/views/user/screens/favourite/favourite.dart';
import 'package:ship_link/views/shared/build%20Side%20Bar/components/rive_assets.dart';

import '../../app_style.dart';

class SideMenuTitle extends StatelessWidget {
  const SideMenuTitle({
    super.key,
    required this.menu,
    required this.press,
    required this.riveonInit,
    required this.isActive,
  });
  final RiveAsset menu;
  final VoidCallback press;
  final ValueChanged<Artboard> riveonInit;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(
            height: 1,
            color: Colors.white24,
          ),
        ),
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 288 : 0,
              left: 0,
              curve: Curves.fastOutSlowIn,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            ListTile(
              onTap: press,
              leading: SizedBox(
                  width: 35,
                  height: 35,
                  child: RiveAnimation.asset(
                    menu.src,
                    artboard: menu.artboard,
                    onInit: riveonInit,
                  )),
              title: Text(menu.title,
                  style: appStyle(18, FontWeight.normal, Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}

void selectedItem(BuildContext context, int index) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    MainScreen.routName,
    (route) => false,
  );
  switch (index) {
    case 0:
      Navigator.of(context).pushReplacementNamed(MainScreen.routName);
      break;
    case 1:
      Navigator.of(context).pushNamed(Profile.routName);
      break;
    case 2:
      Navigator.of(context).pushNamed(HomeScreen.routName);
      break;
    case 3:
      Navigator.of(context).pushNamed(HomeScreen.routName);
      break;
    case 4:
      Navigator.of(context).pushNamed(Favourite.routName);
      break;
  }
}
