import 'package:flutter/material.dart';
import 'package:ship_link/views/driver/screens/DriverHome/driver_home.dart';
import 'package:ship_link/views/driver/screens/DriverProfile/driver_profile.dart';
import 'package:ship_link/views/driver/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/views/driver/screens/OrdersMap/orders_map_screen.dart';
import 'package:ship_link/views/driver/screens/ordersScreen/ordersScreen.dart';
import 'package:ship_link/views/driver/screens/DriverRegister/driver_register.dart';
import 'package:ship_link/views/driver/screens/DriverSignIn/signin_driver.dart';
import 'package:ship_link/views/driver/screens/chat/driver_chat_list_screen.dart';
import 'package:ship_link/views/driver/screens/Splash/driver_splash.dart';
import 'package:ship_link/views/shared/live_tracking_screen.dart';
import 'package:ship_link/views/shared/notification_screen.dart';
import 'package:ship_link/views/shared/settings_screen.dart';
import 'package:ship_link/views/user/screens/reset_password/reset_password_screen.dart';
import 'package:ship_link/views/shared/set_new_password/set_new_password_screen.dart';

final Map<String, WidgetBuilder> driverRoutes = {
  DriverSplash.routName: (context) => const DriverSplash(),
  SignInDriver.routName: (context) => SignInDriver(),
  DriverRegister.routName: (context) => DriverRegister(),
  DriverHome.routName: (context) => DriverHome(),
  MainScreenDriver.routName: (context) => MainScreenDriver(),
  OrdersScreen.routName: (context) => OrdersScreen(),
  OrdersMapScreen.routName: (context) => const OrdersMapScreen(),
  LiveTrackingScreen.routName: (context) => LiveTrackingScreen(),
  DriverProfile.routName: (context) => DriverProfile(),
  NotificationScreen.routName: (context) => NotificationScreen(),
  SettingsScreen.routName: (context) => SettingsScreen(),
  DriverChatListScreen.routName: (context) => const DriverChatListScreen(),
  ResetPasswordScreen.routName: (context) => ResetPasswordScreen(),
  SetNewPasswordScreen.routName: (context) => const SetNewPasswordScreen(),
};

Route<dynamic>? onGenerateDriverRoute(RouteSettings settings) {
  final builder = driverRoutes[settings.name];
  if (builder != null) {
    return DriverSlowRoute(
      builder: builder,
      settings: settings,
    );
  }
  return null;
}

class DriverSlowRoute extends MaterialPageRoute {
  DriverSlowRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}
