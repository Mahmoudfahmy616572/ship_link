import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/build_side_bar/components/rive_assets.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/Profile/profile.dart';
import 'package:ship_link/views/user/screens/favourite/favourite.dart';

import '../../../user/screens/chat/chat_screen.dart';
import '../../notification_screen.dart';
import '../../settings_screen.dart';
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
        Padding(
          padding: EdgeInsets.only(left: 24.w),
          child: Divider(
            height: 1,
            color: AppColors.textPrimary.withOpacity(0.24),
          ),
        ),
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 288.w : 0,
              left: 0,
              curve: Curves.fastOutSlowIn,
              height: 56.h,
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            ListTile(
              onTap: press,
              leading: Container(
                width: 35.w,
                height: 35.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: RiveAnimation.asset(
                  menu.src,
                  artboard: menu.artboard,
                  onInit: riveonInit,
                ),
              ),
              title: Text(context.t.tr(menu.title),
                  style: appStyle(18, FontWeight.normal, AppColors.textPrimary)),
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
      Navigator.of(context).pushNamed(NotificationScreen.routName);
      break;
    case 3:
      Navigator.of(context).pushNamed(SettingsScreen.routName);
      break;
    case 4:
      Navigator.of(context).pushNamed(Favourite.routName);
      break;
    case 5:
      Navigator.of(context).pushNamed(Favourite.routName);
      break;
  }
}
