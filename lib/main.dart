import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubitallProducts/cubit.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';

import 'routs.dart';

void main() {
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
          create: (context) => ProductCubit()..getProductFormCart(),
        ),
        BlocProvider(
          create: (context) => ProductCubit()..products(),
        ),
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // themeMode: ThemeMode.system,
        // darkTheme: ThemeData.dark(),
        // theme: TAppTheme.lightMode,
        home: const Splash(),
        routes: routes,
      ),
    );
  }
}
