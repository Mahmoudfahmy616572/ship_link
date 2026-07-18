import 'package:flutter/material.dart';
import 'package:ship_link/web/data/models/allProducts/all_products.dart';
import 'package:ship_link/web/presentation/layout/web_scaffold.dart';
import 'package:ship_link/web/presentation/screens/home/home_web.dart';
import 'package:ship_link/web/presentation/screens/cart/cart_web.dart';
import 'package:ship_link/web/presentation/screens/checkout/checkout_web.dart';
import 'package:ship_link/web/presentation/screens/checkout/congrats_web.dart';
import 'package:ship_link/web/presentation/screens/orders/orders_web.dart';
import 'package:ship_link/web/presentation/screens/orders/order_detail_web.dart';
import 'package:ship_link/web/presentation/screens/profile/profile_web.dart';
import 'package:ship_link/web/presentation/screens/profile/edit_profile_web.dart';
import 'package:ship_link/web/presentation/screens/addresses/addresses_web.dart';
import 'package:ship_link/web/presentation/screens/settings/settings_web.dart';
import 'package:ship_link/web/presentation/screens/security/security_web.dart';
import 'package:ship_link/web/presentation/screens/favourite/favourite_web.dart';
import 'package:ship_link/web/presentation/screens/notifications/notifications_web.dart';
import 'package:ship_link/web/presentation/screens/payment_methods/payment_methods_web.dart';
import 'package:ship_link/web/presentation/screens/not_found/not_found_web.dart';
import 'package:ship_link/web/presentation/screens/splash/splash_web.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';
import 'package:ship_link/web/presentation/screens/otp/otp_web.dart';
import 'package:ship_link/web/presentation/screens/create_account/create_account_web.dart';
import 'package:ship_link/web/presentation/screens/reset_password/reset_password_web.dart';
import 'package:ship_link/web/presentation/screens/product_details/product_details_web.dart';
import 'package:ship_link/web/presentation/screens/search/search_web.dart';
import 'package:ship_link/web/presentation/screens/chat/chat_list_web.dart';
import 'package:ship_link/web/presentation/screens/chat/order_chat_web.dart';
import 'package:ship_link/web/presentation/screens/chat/support_chat_web.dart';
import 'package:ship_link/web/presentation/screens/tracking/tracking_web.dart';
import 'package:ship_link/web/admin/presentation/screens/login/admin_login_web.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_scaffold.dart';

class WebPageRoute extends PageRouteBuilder {
  final Widget page;
  WebPageRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: FadeTransition(opacity: anim, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

Route<dynamic> onGenerateWebRoute(RouteSettings settings) {
  final name = settings.name;
  if (name == WebScaffold.routName) return WebPageRoute(page: const WebScaffold());
  if (name == HomeWeb.routName) return WebPageRoute(page: const HomeWeb());
  if (name == CartWeb.routName) return WebPageRoute(page: const CartWeb());
  if (name == CheckoutWeb.routName) return WebPageRoute(page: const CheckoutWeb());
  if (name == OrdersWeb.routName) return WebPageRoute(page: const OrdersWeb());
  if (name == ProfileWeb.routName) return WebPageRoute(page: const ProfileWeb());
  if (name == EditProfileWeb.routName) return WebPageRoute(page: const EditProfileWeb());
  if (name == AddressesWeb.routName) return WebPageRoute(page: const AddressesWeb());
  if (name == OrderDetailWeb.routName) {
    final orderId = settings.arguments as int? ?? 0;
    return WebPageRoute(page: OrderDetailWeb(orderId: orderId));
  }
  if (name == SettingsWeb.routName) return WebPageRoute(page: const SettingsWeb());
  if (name == SecurityWeb.routName) return WebPageRoute(page: const SecurityWeb());
  if (name == CongratsWeb.routName) return WebPageRoute(page: const CongratsWeb());
  if (name == FavouriteWeb.routName) return WebPageRoute(page: const FavouriteWeb());
  if (name == NotificationsWeb.routName) return WebPageRoute(page: const NotificationsWeb());
  if (name == PaymentMethodsWeb.routName) return WebPageRoute(page: const PaymentMethodsWeb());
  if (name == SplashWeb.routName) return WebPageRoute(page: const SplashWeb());
  if (name == WelcomeWeb.routName) return WebPageRoute(page: const WelcomeWeb());
  if (name == OtpWeb.routName) {
    final email = settings.arguments as String? ?? '';
    return WebPageRoute(page: OtpWeb(email: email));
  }
  if (name == CreateAccountWeb.routName) return WebPageRoute(page: const CreateAccountWeb());
  if (name == ResetPasswordWeb.routName) return WebPageRoute(page: const ResetPasswordWeb());
  if (name == ProductDetailsWeb.routName) {
    final product = settings.arguments as Product;
    return WebPageRoute(page: ProductDetailsWeb(product: product));
  }
  if (name == SearchWeb.routName) return WebPageRoute(page: const SearchWeb());
  if (name == ChatListWeb.routName) return WebPageRoute(page: const ChatListWeb());
  if (name == OrderChatWeb.routName) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    return WebPageRoute(page: OrderChatWeb(
      orderId: args['orderId'] as int? ?? 0,
      driverId: args['driverId'] as String? ?? '',
    ));
  }
  if (name == SupportChatWeb.routName) return WebPageRoute(page: const SupportChatWeb());
  if (name == TrackingWeb.routName) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    return WebPageRoute(page: TrackingWeb(
      driverId: args['driverId'] as String?,
      orderId: args['orderId'] as int?,
    ));
  }
  if (name == AdminLoginWeb.routName) return WebPageRoute(page: const AdminLoginWeb());
  if (name == AdminScaffoldWeb.routName) return WebPageRoute(page: const AdminScaffoldWeb());
  return WebPageRoute(page: const NotFoundWeb());
}
