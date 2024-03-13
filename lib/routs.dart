import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/ForgotPassword/forgot_password.dart';
import 'package:ship_link/views/user/screens/Home/home_screen.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/Profile/profile.dart';
import 'package:ship_link/views/user/screens/addShippingAddress/add_shipping_address.dart';
import 'package:ship_link/views/user/screens/cart/cart.dart';
import 'package:ship_link/views/user/screens/checkOut/check_out.dart';
import 'package:ship_link/views/user/screens/congrats/congrates.dart';
import 'package:ship_link/views/user/screens/delivered/delivered.dart';
import 'package:ship_link/views/user/screens/favourite/favourite.dart';
import 'package:ship_link/views/user/screens/order/order.dart';
import 'package:ship_link/views/user/screens/otp/otp_screen.dart';
import 'package:ship_link/views/user/screens/sign_in/sign_in_screen.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';

import 'views/user/screens/addPaymentMethod/add_payment_method.dart';
import 'views/user/screens/product/product_screen.dart';
import 'views/user/screens/signup/register/Driver/driver.dart';
import 'views/user/screens/signup/register/Provider/provider.dart';
import 'views/user/screens/signup/register/User/user.dart';
import 'views/user/screens/signup/sign_up.dart';

final Map<String, WidgetBuilder> routes = {
  Splash.routName: (context) => const Splash(),
  Cart.routName: (context) => const Cart(),
  CheckOut.routName: (context) => const CheckOut(),
  Congrates.routName: (context) => const Congrates(),
  Delivered.routName: (context) => const Delivered(),
  Favourite.routName: (context) => const Favourite(),
  ForgotPassword.routName: (context) => const ForgotPassword(),
  HomeScreen.routName: (context) => const HomeScreen(),
  MainScreen.routName: (context) => const MainScreen(),
  Order.routName: (context) => const Order(),
  OtpScreen.routName: (context) => const OtpScreen(),
  ProductScreen.routName: (context) => const ProductScreen(),
  SignIn.routName: (context) => const SignIn(),
  SignUp.routName: (context) => const SignUp(),
  ProviderRegister.routName: (context) => const ProviderRegister(),
  UserRegister.routName: (context) => const UserRegister(),
  DriverRegister.routName: (context) => const DriverRegister(),
  AddShippingAddress.routName: (context) => const AddShippingAddress(),
  AddPaymentMethod.routName: (context) => const AddPaymentMethod(),
  Profile.routName: (context) => const Profile(),
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
