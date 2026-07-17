import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/user/presentation/widgets/build_side_bar/components/rive_assets.dart';
import 'package:ship_link/user/presentation/screens/MainScreen/main_screen.dart';
import 'package:ship_link/user/presentation/screens/Profile/profile.dart';
import 'package:ship_link/user/presentation/screens/favourite/favourite.dart';

import 'package:ship_link/core/widgets/notification_screen.dart';
import 'package:ship_link/core/widgets/settings_screen.dart';
import 'package:ship_link/core/widgets/app_style.dart';

class SideMenuTitle extends StatelessWidget {
  const SideMenuTitle({
    super.key,
    required this.menu,
    required this.press,
    required this.isActive,
  });
  final RiveAsset menu;
  final VoidCallback press;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final titleColor =
        isActive ? AppColors.primary : AppColors.textPrimary;
    final titleWeight = isActive ? FontWeight.w600 : FontWeight.normal;
    return Column(
      children: [
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 288.w : 0,
              left: isRtl ? null : 0,
              right: isRtl ? 0 : null,
              curve: Curves.fastOutSlowIn,
              height: 56.h,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border(
                    left: isRtl
                        ? BorderSide.none
                        : BorderSide(
                            color: AppColors.primary,
                            width: 3,
                          ),
                    right: isRtl
                        ? BorderSide(
                            color: AppColors.primary,
                            width: 3,
                          )
                        : BorderSide.none,
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                onTap: press,
                leading: Container(
                  width: 35.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                  child: menu.controller != null
                      ? RiveWidget(
                          controller: menu.controller!,
                        )
                      : Icon(Icons.circle_outlined,
                          size: 18, color: AppColors.primary.withOpacity(0.5)),
                ),
                title: Text(context.t.tr(menu.title),
                    style: appStyle(16, titleWeight, titleColor)),
                trailing: Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  size: 18,
                  color: isActive
                      ? AppColors.primary.withOpacity(0.7)
                      : AppColors.textSecondary.withOpacity(0.5),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: Divider(
            height: 1,
            color: AppColors.textPrimary.withOpacity(0.06),
          ),
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
