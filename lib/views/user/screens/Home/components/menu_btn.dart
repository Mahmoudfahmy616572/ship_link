import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.only(left: 10, bottom: 40),
          child: Container(
            height: 45,
            width: 45,
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
