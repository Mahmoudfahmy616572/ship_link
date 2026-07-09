import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart' hide Animation;
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/user/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/user/presentation/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/user/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/user/presentation/cubits/homeFilter/home_filter_cubit.dart';
import 'package:ship_link/user/domain/repositories/cart_repository.dart';
import 'package:ship_link/user/domain/repositories/favourite_repository.dart';
import 'package:ship_link/user/domain/repositories/home_repository.dart';
import 'package:ship_link/user/presentation/screens/Home/components/body.dart';
import 'package:ship_link/user/presentation/widgets/build_side_bar/build_side_bar.dart';

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

  BooleanInput? isSideBarClosed;
  bool isSideMenuClosed = true;
  RiveWidgetController? _menuController;

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
    _initMenuRive();
  }

  Future<void> _initMenuRive() async {
    final file = (await File.asset("assets/RiveAssets/menu_button.riv",
        riveFactory: Factory.rive))!;
    _menuController = RiveWidgetController(
      file,
      artboardSelector: ArtboardDefault(),
      stateMachineSelector: StateMachineSelector.byName("State Machine"),
    );
    isSideBarClosed = _menuController?.stateMachine?.boolean("isOpen");
    isSideBarClosed?.value = true;
    setState(() {});
  }

  void _toggleMenu() {
    isSideBarClosed?.value = !isSideBarClosed!.value;
    if (isSideMenuClosed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      isSideMenuClosed = isSideBarClosed!.value;
    });
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
            getIt.get<HomeRepository>(),
          )..getAllproducts(),
        ),
        BlocProvider(
          create: (_) => GetTopSellerCubit(
            getIt.get<HomeRepository>(),
          )..getTopSellerProducts(),
        ),
        BlocProvider(
          create: (_) => GetFromCartCubit(
            getIt.get<CartRepository>(),
          )..getProductFromCart(),
        ),
        BlocProvider(
          create: (_) => AddToCartCubit(
            getIt.get<CartRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => FavouriteCubit(
            getIt.get<FavouriteRepository>(),
          )..getFavourites(),
        ),
        BlocProvider(
          create: (_) => HomeFilterCubit(),
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
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Body(
                        menuController: _menuController,
                        onMenuTap: _toggleMenu,
                      ))),
            ),
          ),
        ]),
      ),
    );
  }
}
