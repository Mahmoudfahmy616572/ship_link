import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveicesimpl.dart';
import 'package:ship_link/data/services/favouriteServices/favourite_services_impl.dart';
import 'package:ship_link/data/services/homeServeice/home_serveices_impl.dart';
import 'package:ship_link/views/user/screens/Home/components/body.dart';
import 'package:ship_link/views/shared/build_side_bar/build_side_bar.dart';
import 'package:ship_link/views/shared/build_side_bar/components/rive_utiles.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetAllProuductsCubit(
            getIt.get<HomeServeicesImpl>(),
          )..getAllproducts(),
        ),
        BlocProvider(
          create: (_) => GetTopSellerCubit(
            getIt.get<HomeServeicesImpl>(),
          )..getTopSellerProducts(),
        ),
        BlocProvider(
          create: (_) => GetFromCartCubit(
            getIt.get<CartServeicesImpl>(),
          )..getProductFromCart(),
        ),
        BlocProvider(
          create: (_) => AddToCartCubit(
            getIt.get<CartServeicesImpl>(),
          ),
        ),
        BlocProvider(
          create: (_) => FavouriteCubit(
            getIt.get<FavouriteServiceImpl>(),
          )..getFavourites(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
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
      ),
    );
  }
}
