// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/views/shared/build%20Side%20Bar/components/rive_utiles.dart';

import 'components/rive_assets.dart';
import 'components/side_menu_tile.dart';
import 'components/top_logo.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  RiveAsset selectedMenu = sideMenue.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: const Color(0xFF151516),
        child: Column(
          children: [
            TopLogo(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...sideMenue.map((menu) => SideMenuTitle(
                      menu: menu,
                      riveonInit: (artboard) {
                        StateMachineController controller =
                            RiveUtils.getRiveController(artboard,
                                stateMachineName: menu.stateMachineName);

                        menu.input = controller.findSMI("active") as SMIBool;
                      },
                      press: () {
                        menu.input!.change(true);
                        Future.delayed(Duration(seconds: 1), () {
                          menu.input!.change(false);

/////
                          selectedItem(context, menu.index);
/////
                        });
                        setState(() {
                          selectedMenu = menu;
                        });
                      },
                      isActive: selectedMenu == menu,
                    )),

                    
              ],
            )
          ],
        ),
      ),
    );
  }
}
