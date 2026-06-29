import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:rive/rive.dart';

class MenuBTN extends StatelessWidget {
  const MenuBTN({
    super.key,
    this.onTap,
    this.riveOnIt,
  });
  final void Function()? onTap;
  final void Function(Artboard)? riveOnIt;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, bottom: 40.h),
          child: Container(
            height: 45.h,
            width: 45.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, offset: Offset(0, 3), blurRadius: 8)
              ],
            ),
            child: RiveAnimation.asset(
              "assets/RiveAssets/menu_button.riv",
              onInit: riveOnIt,
            ),
          ),
        ),
      ),
    );
  }
}
