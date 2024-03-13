// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/Profile/profile.dart';
import 'package:ship_link/views/user/screens/favourite/favourite.dart';
import 'package:ship_link/views/shared/app_style.dart';

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF151516),
      child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Image.asset("assets/images/signin Logo.png"),
                  Text(
                    "Ship Link",
                    style: appStyle(20, FontWeight.bold, Colors.white),
                  )
                ],
              )
              // UserAccountsDrawerHeader(
              //   decoration: const BoxDecoration(
              //     image: DecorationImage(
              //         image: AssetImage("assets/images/car.png"),
              //         fit: BoxFit.cover),
              //   ),
              //   // currentAccountPicture: const ImageUrl(),
              //   accountEmail: Text("userr.email!"),
              //   accountName: Text("mahmoud"),
              // ),
              ,
              const SizedBox(
                height: 20,
              ),
              ListTile(
                title: const DrowerWidget(
                  txt: 'Home',
                  svgImage: 'assets/icons/home.svg',
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const DrowerWidget(
                  txt: 'Category',
                  svgImage: 'assets/icons/category.svg',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, MainScreen.routName);
                },
              ),
              ListTile(
                title: const DrowerWidget(
                  txt: 'Favourite',
                  svgImage: 'assets/icons/favourite.svg',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Favourite.routName);
                },
              ),
              ListTile(
                title: const DrowerWidget(
                  txt: 'Profile',
                  svgImage: 'assets/icons/profile.svg',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Profile.routName);
                },
              ),
              ListTile(
                title: const DrowerWidget(
                  txt: 'explore',
                  svgImage: 'assets/icons/explore.svg',
                ),
                onTap: () {},
              ),
              ListTile(
                title: const DrowerWidget(
                  txt: 'Setting',
                  svgImage: 'assets/icons/setting.svg',
                ),
                onTap: () {},
              ),
              ListTile(
                title: const DrowerWidget(
                  txt: 'Logout',
                  svgImage: 'assets/icons/logout.svg',
                ),
                onTap: () {},
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            child: const Text("Developed by MahmoudFahmy © 2023",
                style: TextStyle(fontSize: 14, color: Colors.white)),
          )
        ],
      ),
    );
  }
}

class DrowerWidget extends StatelessWidget {
  const DrowerWidget({
    super.key,
    required this.txt,
    required this.svgImage,
  });
  final String txt;
  final String svgImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.transparent),
      child: Row(
        children: [
          SvgPicture.asset(svgImage,
              height: 24, width: 24, color: Colors.white),
          const SizedBox(
            width: 10,
          ),
          Text(
            txt,
            style: appStyle(18, FontWeight.w600, Colors.white),
          ),
        ],
      ),
    );
  }
}
