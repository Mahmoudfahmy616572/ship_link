// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/build_side_bar/components/rive_utiles.dart';

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
      buildWhen: (prev, cur) => false,
      builder: (context, state) {
        var cubit = AuthCubit.get(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            width: 288.w,
            height: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  TopLogo(),
                  SizedBox(
                    height: 20.h,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 24.w, bottom: 20.h),
                        child: Text(
                          context.t.tr('browse'),
                          style:
                              appStyle(20, FontWeight.normal, AppColors.textPrimary.withOpacity(0.7)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: Divider(
                          height: 1,
                          color: AppColors.textPrimary.withOpacity(0.24),
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
                      Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: Divider(
                          height: 1,
                          color: AppColors.textPrimary.withOpacity(0.24),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24.w, top: 20.h, bottom: 20.h),
                        child: Text(
                          context.t.tr('log_out_drawer'),
                          style:
                              appStyle(20, FontWeight.normal, AppColors.textPrimary.withOpacity(0.7)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.cta,
                              textStyle:
                                  appStyle(18, FontWeight.w500, Colors.white),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.r))),
                            ),
                            onPressed: () async {
                              await cubit.signOut();
                              CustomSnackBar.displaySuccessMotionToast(
                                  context.t.tr('logout_successful'), context);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, SignIn.routName, (route) => false);
                            },
                            child: Text(
                              context.t.tr('log_out_drawer'),
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