import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/live_tracking_screen.dart';
import 'package:ship_link/core/widgets/notification_screen.dart';
import 'package:ship_link/core/widgets/settings_screen.dart';
import 'package:ship_link/user/presentation/screens/Home/components/top_seller_screen.dart';
import 'package:ship_link/user/presentation/screens/Home/home_screen.dart';
import 'package:ship_link/user/presentation/screens/MainScreen/main_screen.dart';
import 'package:ship_link/user/presentation/screens/Profile/profile.dart';
import 'package:ship_link/user/presentation/screens/cart/cart.dart';
import 'package:ship_link/user/presentation/screens/checkOutPage/check_out.dart';
import 'package:ship_link/user/presentation/screens/congrats/congrates.dart';
import 'package:ship_link/user/presentation/screens/delivered/delivered.dart';
import 'package:ship_link/user/presentation/screens/favourite/favourite.dart';
import 'package:ship_link/user/presentation/screens/order/order.dart';
import 'package:ship_link/user/presentation/screens/otp/otp_screen.dart';
import 'package:ship_link/user/presentation/screens/location_picker/location_picker.dart';
import 'package:ship_link/user/presentation/screens/register/register_screen.dart';
import 'package:ship_link/user/presentation/screens/sign_in/sign_in_screen.dart';
import 'package:ship_link/user/presentation/screens/splash/splash_screen.dart';
import 'package:ship_link/user/presentation/screens/welcome/welcome_screen.dart';
import 'package:ship_link/user/presentation/screens/login/login_screen.dart';
import 'package:ship_link/user/presentation/screens/create_account/create_account_screen.dart';
import 'package:ship_link/user/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:ship_link/user/presentation/screens/security/security_screen.dart';
import 'package:ship_link/user/presentation/screens/address_book/address_book_screen.dart';
import 'package:ship_link/user/presentation/screens/paymentMethods/payment_methods_screen.dart';
import 'package:ship_link/user/presentation/screens/chat/chat_screen.dart';
import 'package:ship_link/user/presentation/screens/edit_profile/edit_profile_screen.dart';
import 'package:ship_link/user/presentation/screens/order_detail/order_detail.dart';
import 'package:ship_link/user/presentation/screens/signup/register/User/user.dart';
import 'package:ship_link/user/presentation/screens/signup/sign_up.dart';
import 'package:ship_link/user/presentation/screens/tracking/driver_tracking_screen.dart';
import 'package:ship_link/core/widgets/set_new_password/set_new_password_screen.dart';
final Map<String, WidgetBuilder> userRoutes = {
  Splash.routName: (context) => Splash(),
  Cart.routName: (context) => Cart(),
  Congrates.routName: (context) => Congrates(),
  Delivered.routName: (context) {
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          args != null ? context.t.tr(args) : context.t.tr('order_history'),
          style: appStyle(18, FontWeight.w600, AppColors.textPrimary),
        ),
      ),
      body: SafeArea(child: Delivered(statusFilter: args)),
    );
  },
  Favourite.routName: (context) => Favourite(),
  HomeScreen.routName: (context) => HomeScreen(),
  MainScreen.routName: (context) => MainScreen(),
  Order.routName: (context) => Order(),
  OtpScreen.routName: (context) => OtpScreen(),
  SignIn.routName: (context) => SignIn(),
  SignUp.routName: (context) => SignUp(),
  UserRegister.routName: (context) => UserRegister(),
  Profile.routName: (context) => Profile(),
  TopSellerScreen.routName: (context) => TopSellerScreen(),
  SettingsScreen.routName: (context) => SettingsScreen(),
  LiveTrackingScreen.routName: (context) => LiveTrackingScreen(),
  NotificationScreen.routName: (context) => const NotificationScreen(),
  LocationPicker.routName: (context) => LocationPicker(),
  RegisterScreen.routName: (context) => RegisterScreen(),
  WelcomeScreen.routName: (context) => WelcomeScreen(),
  LoginScreen.routName: (context) => LoginScreen(),
  CreateAccountScreen.routName: (context) => CreateAccountScreen(),
  ResetPasswordScreen.routName: (context) => ResetPasswordScreen(),
  SecurityScreen.routName: (context) => SecurityScreen(),
  SetNewPasswordScreen.routName: (context) => const SetNewPasswordScreen(),
  AddressBookScreen.routName: (context) => AddressBookScreen(),
  PaymentMethodsScreen.routName: (context) => const PaymentMethodsScreen(),
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
