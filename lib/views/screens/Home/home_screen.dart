import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/views/screens/Home/components/body.dart';
import 'package:ship_link/views/shared/build%20Side%20Bar/build_side_bar.dart';
import 'package:ship_link/views/shared/build%20Side%20Bar/components/rive_utiles.dart';

import 'components/menu_btn.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static String routName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleanimation;

  SMIBool? isSideBarClosed;
  bool isSideMenuClosed = true;
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    scaleanimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151516),

      body: Stack(children: [
        AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            left: isSideMenuClosed ? -288 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            child: const SideBar()),
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(animation.value - 30 * animation.value * pi / 180),
          child: Transform.translate(
            offset: Offset(animation.value * 288, 0),
            child: Transform.scale(
                scale: scaleanimation.value,
                child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Body())),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: 16,
          left: isSideMenuClosed ? 0 : 220,
          curve: Curves.fastOutSlowIn,
          child: MenuBTN(
            riveOnIt: (artboard) {
              StateMachineController controller = RiveUtils.getRiveController(
                artboard,
                stateMachineName: "State Machine",
              );
              isSideBarClosed = controller.findSMI("isOpen") as SMIBool;
              isSideBarClosed!.value = true;
            },
            onTap: () {
              isSideBarClosed!.value = !isSideBarClosed!.value;
              if (isSideMenuClosed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
              setState(() {
                isSideMenuClosed = isSideBarClosed!.value;
              });
            },
          ),
        ),
      ]),
    );
  }
}
