import 'package:flutter/material.dart';
import 'routs.dart';
import 'views/driver/screens/MainScreen/main_screen_driver.dart';

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
      home: const MainScreenDriver(),
      routes: routes,
    );
  }
}
