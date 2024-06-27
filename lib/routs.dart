import 'package:flutter/material.dart';
import 'package:ship_link/views/driver/screens/DriverHome/driver_home.dart';
import 'package:ship_link/views/driver/screens/DriverProfile/driver_profile.dart';
import 'package:ship_link/views/driver/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/views/driver/screens/ordersScreen/ordersScreen.dart';
import 'package:ship_link/views/user/screens/ForgotPassword/forgot_password.dart';
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
import 'package:ship_link/views/user/screens/sign_in/sign_in_screen.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';

import 'views/driver/screens/DriverRegister/driver_register.dart';
import 'views/driver/screens/DriverSignIn/signin_driver.dart';
import 'views/user/screens/signup/register/User/user.dart';
import 'views/user/screens/signup/sign_up.dart';

final Map<String, WidgetBuilder> routes = {
  Splash.routName: (context) => const Splash(),
  Cart.routName: (context) => const Cart(),
  Congrates.routName: (context) => const Congrates(),
  Delivered.routName: (context) => const Delivered(),
  Favourite.routName: (context) => const Favourite(),
  ForgotPassword.routName: (context) => const ForgotPassword(),
  HomeScreen.routName: (context) => const HomeScreen(),
  MainScreen.routName: (context) => const MainScreen(),
  Order.routName: (context) => const Order(),
  OtpScreen.routName: (context) => const OtpScreen(),
  SignIn.routName: (context) => const SignIn(),
  SignUp.routName: (context) => const SignUp(),
  UserRegister.routName: (context) => const UserRegister(),
  DriverRegister.routName: (context) => const DriverRegister(),
  Profile.routName: (context) => const Profile(),
  DriverHome.routName: (context) => const DriverHome(),
  MainScreenDriver.routName: (context) => const MainScreenDriver(),
  OrdersScreen.routName: (context) => const OrdersScreen(),
  DriverProfile.routName: (context) => const DriverProfile(),
  SignInDriver.routName: (context) => const SignInDriver(),
  CheckOutPage.routName: (context) => CheckOutPage(),
};

final otpInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(vertical: 15),
  enabledBorder: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  border: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.circular(11), borderSide: BorderSide.none);
}
