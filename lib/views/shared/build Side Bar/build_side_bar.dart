// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/build%20Side%20Bar/components/rive_utiles.dart';

import '../../user/screens/sign_in/sign_in_screen.dart';
import '../snackBar/snack_bar.dart';
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        var cubit = AuthCubit.get(context);
        return Scaffold(
          body: Container(
            width: 288,
            height: double.infinity,
            color: const Color(0xFF151516),
            child: SafeArea(
              child: Column(
                children: [
                  TopLogo(),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 24, bottom: 20),
                        child: Text(
                          "BROWSE",
                          style:
                              appStyle(20, FontWeight.normal, Colors.white70),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 24),
                        child: Divider(
                          height: 1,
                          color: Colors.white24,
                        ),
                      ),
                      ...sideMenue.map((menu) => SideMenuTitle(
                            menu: menu,
                            riveonInit: (artboard) {
                              StateMachineController controller =
                                  RiveUtils.getRiveController(artboard,
                                      stateMachineName: menu.stateMachineName);

                              menu.input =
                                  controller.findSMI("active") as SMIBool;
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
                      const Padding(
                        padding: EdgeInsets.only(left: 24),
                        child: Divider(
                          height: 1,
                          color: Colors.white24,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, top: 20, bottom: 20),
                        child: Text(
                          "LOG OUT",
                          style:
                              appStyle(20, FontWeight.normal, Colors.white70),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue[200],
                              textStyle:
                                  appStyle(18, FontWeight.w500, Colors.black),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            onPressed: () async {
                              await cubit.signOut();
                              CustomSnackBar.displaySuccessMotionToast(
                                  "Logout Successfuly", context);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, SignIn.routName, (route) => false);
                            },
                            child: Text(
                              "Logout",
                              // style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
