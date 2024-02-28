import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/screens/splash/splash_screen.dart';

import 'routs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // themeMode: ThemeMode.system,
      // darkTheme: ThemeData.dark(),
      // theme: TAppTheme.lightMode,
      home: const Splash(),
      routes: routes,
    );
  }
}
