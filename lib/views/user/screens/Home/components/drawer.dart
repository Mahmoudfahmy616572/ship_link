import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/Profile/profile.dart';
import 'package:ship_link/views/user/screens/favourite/favourite.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/notification_screen.dart';

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              Image.asset("assets/images/signin Logo.png"),
              Text(
                context.t.tr('ship_link'),
                style: appStyle(20, FontWeight.bold, AppColors.textPrimary),
              ),
              SizedBox(height: 20.h),
              _drawerItem(context, context.t.tr('home_drawer'), 'assets/icons/home.svg', () {
                Navigator.pop(context);
              }),
              _drawerItem(context, context.t.tr('category'), 'assets/icons/category.svg', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, MainScreen.routName);
              }),
              _drawerItem(context, context.t.tr('notifications'), 'assets/icons/NotificationBell.svg', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, NotificationScreen.routName);
              }),
              _drawerItem(context, context.t.tr('favourites_drawer'), 'assets/icons/favourite.svg', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Favourite.routName);
              }),
              _drawerItem(context, context.t.tr('profile_drawer'), 'assets/icons/profile.svg', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Profile.routName);
              }),
              _drawerItem(context, context.t.tr('explore'), 'assets/icons/explore.svg', () {}),
              _drawerItem(context, context.t.tr('settings'), 'assets/icons/setting.svg', () {}),
              _drawerItem(context, context.t.tr('log_out_drawer'), 'assets/icons/logout.svg', () {}),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Container(
            margin: EdgeInsets.only(bottom: 15.h),
            padding: EdgeInsets.all(20.w),
            child: Text(context.t.tr('developed_by'),
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String txt, String svgImage, VoidCallback onTap) {
    return ListTile(
      leading: SvgPicture.asset(svgImage,
          height: 24, width: 24, color: AppColors.cta),
      title: Text(
        txt,
        style: appStyle(18, FontWeight.w600, AppColors.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
