import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/serveices_locators.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveicesimpl.dart';
import 'package:ship_link/data/services/homeServeice/home_serveices_impl.dart';
import 'package:ship_link/routs.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';

void main() {
  setupServeiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetAllProuductsCubit(
            getIt.get<HomeServeicesImpl>(),
          )..getAllproducts(),
        ),
        BlocProvider(
          create: (context) => AddToCartCubit(
            getIt.get<CartServeicesImpl>(),
          )..addToCart(),
        ),
        BlocProvider(
          create: (context) => GetFromCartCubit(
            getIt.get<CartServeicesImpl>(),
          )..getProductFromCart(),
        ),
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
      ],
      child: MaterialApp(
        routes: routes,
        initialRoute: Splash.routName,

        debugShowCheckedModeBanner: false,
        // themeMode: ThemeMode.system,
        // darkTheme: ThemeData.dark(),
        // theme: TAppTheme.lightMode,
      ),
    );
  }
}
