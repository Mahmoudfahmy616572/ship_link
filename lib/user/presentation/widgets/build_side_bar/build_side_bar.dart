import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:rive/rive.dart' hide Animation;
import 'package:ship_link/core/widgets/app_style.dart';

import 'package:ship_link/user/presentation/widgets/build_side_bar/components/rive_assets.dart';
import 'package:ship_link/user/presentation/widgets/build_side_bar/components/side_menu_tile.dart';
import 'package:ship_link/user/presentation/widgets/build_side_bar/components/top_logo.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final _loaded = ValueNotifier<bool>(false);
  final _selectedMenuIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  Future<void> _initRive() async {
    final file = (await File.asset("assets/RiveAssets/icons.riv",
        riveFactory: Factory.rive))!;
    for (final menu in sideMenue) {
      menu.controller = RiveWidgetController(
        file,
        artboardSelector: ArtboardSelector.byName(menu.artboard),
        stateMachineSelector:
            StateMachineSelector.byName(menu.stateMachineName),
      );
      menu.input = menu.controller!.stateMachine?.boolean("active");
    }
    _loaded.value = true;
  }

  @override
  void dispose() {
    _loaded.dispose();
    _selectedMenuIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_loaded, _selectedMenuIndex]),
      builder: (context, _) {
        final selIdx = _selectedMenuIndex.value;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            width: 288.w,
            height: double.infinity,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TopLogo(),
                    SizedBox(height: 16.h),
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
                              press: () {
                                menu.input?.value = true;
                                Future.delayed(Duration(seconds: 1), () {
                                  menu.input?.value = false;
                                  selectedItem(context, menu.index);
                                });
                                _selectedMenuIndex.value = sideMenue.indexOf(menu);
                              },
                              isActive: sideMenue[selIdx] == menu,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
