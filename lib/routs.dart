import 'package:flutter/material.dart';
import 'package:ship_link/views/driver/screens/DriverHome/driver_home.dart';
import 'package:ship_link/views/driver/screens/DriverProfile/driver_profile.dart';
import 'package:ship_link/views/driver/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/views/driver/screens/ordersScreen/ordersScreen.dart';
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

import 'views/driver/screens/DriverRegister/driver_register.dart';
import 'views/driver/screens/DriverSignIn/signin_driver.dart';
import 'views/user/screens/addPaymentMethod/add_payment_method.dart';
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
  SignIn.routName: (context) => const SignIn(),
  SignUp.routName: (context) => const SignUp(),
  ProviderRegister.routName: (context) => const ProviderRegister(),
  UserRegister.routName: (context) => const UserRegister(),
  DriverRegister.routName: (context) => const DriverRegister(),
  AddShippingAddress.routName: (context) => const AddShippingAddress(),
  AddPaymentMethod.routName: (context) => const AddPaymentMethod(),
  Profile.routName: (context) => const Profile(),
  DriverHome.routName: (context) => const DriverHome(),
  MainScreenDriver.routName: (context) => const MainScreenDriver(),
  OrdersScreen.routName: (context) => const OrdersScreen(),
  DriverProfile.routName: (context) => const DriverProfile(),
  SignInDriver.routName: (context) => const SignInDriver(),
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

// abstract class RouteApp {
//   static final router = GoRouter(
//     routes: [
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const Splash(),
//       ),
//       GoRoute(
//         path: '/Cart',
//         builder: (context, state) => const Cart(),
//       ),
//       GoRoute(
//         path: '/CheckOut',
//         builder: (context, state) => const CheckOut(),
//       ),
//       GoRoute(
//         path: '/Congrates',
//         builder: (context, state) => const Congrates(),
//       ),
//       GoRoute(
//         path: '/Delivered',
//         builder: (context, state) => const Delivered(),
//       ),
//       GoRoute(
//         path: '/Favourite',
//         builder: (context, state) => const Favourite(),
//       ),
//       GoRoute(
//         path: '/ForgotPassword',
//         builder: (context, state) => const ForgotPassword(),
//       ),
//       GoRoute(
//         path: '/HomeScreen',
//         builder: (context, state) => const HomeScreen(),
//       ),
//       GoRoute(
//         path: '/MainScreen',
//         builder: (context, state) => const MainScreen(),
//       ),
//       GoRoute(
//         path: '/Order',
//         builder: (context, state) => const Order(),
//       ),
//       GoRoute(
//         path: '/OtpScreen',
//         builder: (context, state) => const OtpScreen(),
//       ),
//       // GoRoute(
//       //   path: '/ProductScreen',
//       //   builder: (context, state) => ProductScreen(
//       //     index: state.extra as int,
//       //   ),
//       // ),
//       // GoRoute(
//       //     path: '/ProductScreen',
//       //     builder: (context, state) => BlocProvider(
//       //           create: (context) =>
//       //               AddToCartCubit(getIt.get<CartServeicesImpl>()),
//       //           child: ProductScreen(index:,),
//       //         )),
//       GoRoute(
//         path: '/SignIn',
//         builder: (context, state) => const SignIn(),
//       ),
//       GoRoute(
//         path: '/SignUp',
//         builder: (context, state) => const SignUp(),
//       ),
//       GoRoute(
//         path: '/ProviderRegister',
//         builder: (context, state) => const ProviderRegister(),
//       ),
//       GoRoute(
//         path: '/UserRegister',
//         builder: (context, state) => const UserRegister(),
//       ),
//       GoRoute(
//         path: '/AddShippingAddress',
//         builder: (context, state) => const AddShippingAddress(),
//       ),
//       GoRoute(
//         path: '/AddPaymentMethod',
//         builder: (context, state) => const AddPaymentMethod(),
//       ),
//       GoRoute(
//         path: '/DriverHome',
//         builder: (context, state) => const DriverHome(),
//       ),
//       GoRoute(
//         path: '/MainScreenDriver',
//         builder: (context, state) => const MainScreenDriver(),
//       ),
//       GoRoute(
//         path: '/NotificationScreen',
//         builder: (context, state) => const NotificationScreen(),
//       ),
//       GoRoute(
//         path: '/Chat',
//         builder: (context, state) => const Chat(),
//       ),
//     ],
//   );
// }
