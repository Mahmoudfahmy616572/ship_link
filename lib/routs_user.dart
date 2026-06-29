import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/live_tracking_screen.dart';
import 'package:ship_link/views/shared/notification_screen.dart';
import 'package:ship_link/views/shared/settings_screen.dart';
import 'package:ship_link/views/user/screens/Home/components/top_seller_screen.dart';
import 'package:ship_link/views/user/screens/Home/home_screen.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/Profile/profile.dart';
import 'package:ship_link/views/user/screens/cart/cart.dart';
import 'package:ship_link/views/user/screens/checkOutPage/check_out.dart';
import 'package:ship_link/views/user/screens/congrats/congrates.dart';
import 'package:ship_link/views/user/screens/delivered/delivered.dart';
import 'package:ship_link/views/user/screens/favourite/favourite.dart';
import 'package:ship_link/views/user/screens/order/order.dart';
import 'package:ship_link/views/user/screens/otp/otp_screen.dart';
import 'package:ship_link/views/user/screens/location_picker/location_picker.dart';
import 'package:ship_link/views/user/screens/register/register_screen.dart';
import 'package:ship_link/views/user/screens/sign_in/sign_in_screen.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';
import 'package:ship_link/views/user/screens/welcome/welcome_screen.dart';
import 'package:ship_link/views/user/screens/login/login_screen.dart';
import 'package:ship_link/views/user/screens/create_account/create_account_screen.dart';
import 'package:ship_link/views/user/screens/reset_password/reset_password_screen.dart';
import 'package:ship_link/views/user/screens/security/security_screen.dart';
import 'package:ship_link/views/user/screens/address_book/address_book_screen.dart';
import 'package:ship_link/views/user/screens/chat/chat_screen.dart';
import 'package:ship_link/views/user/screens/edit_profile/edit_profile_screen.dart';
import 'package:ship_link/views/user/screens/order_detail/order_detail.dart';
import 'package:ship_link/views/user/screens/signup/register/User/user.dart';
import 'package:ship_link/views/user/screens/tracking/driver_tracking_screen.dart';

final Map<String, WidgetBuilder> userRoutes = {
  Splash.routName: (context) => Splash(),
  Cart.routName: (context) => Cart(),
  Congrates.routName: (context) => Congrates(),
  Delivered.routName: (context) {
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    return Delivered(statusFilter: args);
  },
  Favourite.routName: (context) => Favourite(),
  HomeScreen.routName: (context) => HomeScreen(),
  MainScreen.routName: (context) => MainScreen(),
  Order.routName: (context) => Order(),
  OtpScreen.routName: (context) => OtpScreen(),
  SignIn.routName: (context) => SignIn(),
  UserRegister.routName: (context) => UserRegister(),
  Profile.routName: (context) => Profile(),
  TopSellerScreen.routName: (context) => TopSellerScreen(),
  SettingsScreen.routName: (context) => SettingsScreen(),
  LiveTrackingScreen.routName: (context) => LiveTrackingScreen(),
  NotificationScreen.routName: (context) => NotificationScreen(),
  LocationPicker.routName: (context) => LocationPicker(),
  RegisterScreen.routName: (context) => RegisterScreen(),
  WelcomeScreen.routName: (context) => WelcomeScreen(),
  LoginScreen.routName: (context) => LoginScreen(),
  CreateAccountScreen.routName: (context) => CreateAccountScreen(),
  ResetPasswordScreen.routName: (context) => ResetPasswordScreen(),
  SecurityScreen.routName: (context) => SecurityScreen(),
  AddressBookScreen.routName: (context) => AddressBookScreen(),
  EditProfileScreen.routName: (context) => EditProfileScreen(),
  CheckOutPage.routName: (context) => CheckOutPage(),
  Chat.routName: (context) => Chat(),
  DriverTrackingScreen.routName: (context) => DriverTrackingScreen(orderId: ''),
};

Route<dynamic>? onGenerateUserRoute(RouteSettings settings) {
  if (settings.name == OrderDetail.routName) {
    final orderId = settings.arguments as int;
    return UserSlowRoute(
      builder: (_) => OrderDetail(orderId: orderId),
      settings: settings,
    );
  }
  final builder = userRoutes[settings.name];
  if (builder != null) {
    return UserSlowRoute(
      builder: builder,
      settings: settings,
    );
  }
  return null;
}

class UserSlowRoute extends MaterialPageRoute {
  UserSlowRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}
