import 'package:flutter/material.dart';
import 'package:ship_link/views/web/layout/web_scaffold.dart';
import 'package:ship_link/views/web/screens/home/home_web.dart';
import 'package:ship_link/views/web/screens/login/login_web.dart';
import 'package:ship_link/views/web/screens/register/register_web.dart';
import 'package:ship_link/views/web/screens/cart/cart_web.dart';
import 'package:ship_link/views/web/screens/checkout/checkout_web.dart';
import 'package:ship_link/views/web/screens/checkout/congrats_web.dart';
import 'package:ship_link/views/web/screens/orders/orders_web.dart';
import 'package:ship_link/views/web/screens/orders/order_detail_web.dart';
import 'package:ship_link/views/web/screens/profile/profile_web.dart';
import 'package:ship_link/views/web/screens/profile/edit_profile_web.dart';
import 'package:ship_link/views/web/screens/addresses/addresses_web.dart';
import 'package:ship_link/views/web/screens/settings/settings_web.dart';
import 'package:ship_link/views/web/screens/security/security_web.dart';
import 'package:ship_link/views/web/screens/favourite/favourite_web.dart';
import 'package:ship_link/views/web/screens/notifications/notifications_web.dart';
import 'package:ship_link/views/web/screens/not_found/not_found_web.dart';

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
  if (name == LoginWeb.routName) return WebPageRoute(page: const LoginWeb());
  if (name == RegisterWeb.routName) return WebPageRoute(page: const RegisterWeb());
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
  return WebPageRoute(page: const NotFoundWeb());
}
