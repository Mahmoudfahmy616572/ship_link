import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _buildUserHeader(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metaName = user?.userMetadata?['full_name'] as String?;
    final displayName = (metaName != null && metaName.trim().isNotEmpty)
        ? metaName.trim()
        : (user?.email ?? context.t.tr('guest'));
    final email = user?.email ?? '';
    final initials = _initials(displayName);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.primary.withAlpha(18),
            child: Text(
              initials,
              style: appStyle(16, FontWeight.w700, AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: appStyle(14, FontWeight.w600, AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      email,
                      style:
                          appStyle(12, FontWeight.normal, AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return ListenableBuilder(
      listenable: Listenable.merge([_loaded, _selectedMenuIndex]),
      builder: (context, _) {
        final selIdx = _selectedMenuIndex.value;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            width: 288.w,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                left: isRtl
                    ? BorderSide(
                        color: AppColors.textPrimary.withOpacity(0.08),
                        width: 1,
                      )
                    : BorderSide.none,
                right: isRtl
                    ? BorderSide.none
                    : BorderSide(
                        color: AppColors.textPrimary.withOpacity(0.08),
                        width: 1,
                      ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TopLogo(),
                          _buildUserHeader(context),
                          SizedBox(height: 10.h),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 24.w, right: 24.w, bottom: 6.h),
                            child: Text(
                              context.t.tr('browse').toUpperCase(),
                              style: appStyle(12, FontWeight.w700,
                                  AppColors.textPrimary.withOpacity(0.4)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 24.w, right: 24.w),
                            child: Divider(
                              height: 1,
                              color: AppColors.textPrimary.withOpacity(0.18),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...sideMenue.map((menu) => SideMenuTitle(
                                      menu: menu,
                                      press: () {
                                        menu.input?.value = true;
                                        Future.delayed(Duration(seconds: 1), () {
                                          menu.input?.value = false;
                                          selectedItem(context, menu.index);
                                        });
                                        _selectedMenuIndex.value =
                                            sideMenue.indexOf(menu);
                                      },
                                      isActive: sideMenue[selIdx] == menu,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 4.r,
                          height: 4.r,
                          decoration: BoxDecoration(
                            color: AppColors.cta,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          context.t.tr('developed_by'),
                          style: appStyle(13, FontWeight.normal,
                              AppColors.textPrimary.withOpacity(0.4)),
                        ),
                      ],
                    ),
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
