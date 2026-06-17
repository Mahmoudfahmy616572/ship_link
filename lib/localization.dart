import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'ShipLink',
      'home': 'Home',
      'search': 'Search',
      'cart': 'Cart',
      'profile': 'Profile',
      'orders': 'Orders',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'sign_out': 'Sign Out',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'shipments': 'Shipments',
      'track_shipment': 'Track Shipment',
      'delivery_address': 'Delivery Address',
      'payment': 'Payment',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'top_sellers': 'Top Sellers',
      'all_products': 'All Products',
      'add_to_cart': 'Add to Cart',
      'checkout': 'Checkout',
      'total': 'Total',
      'driver_mode': 'Driver Mode',
      'accept_order': 'Accept Order',
      'live_tracking': 'Live Tracking',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'orders_history': 'Orders History',
    },
    'ar': {
      'app_name': 'ShipLink',
      'home': 'الرئيسية',
      'search': 'بحث',
      'cart': 'السلة',
      'profile': 'الملف الشخصي',
      'orders': 'الطلبات',
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب',
      'sign_out': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'name': 'الاسم',
      'shipments': 'الشحنات',
      'track_shipment': 'تتبع الشحنة',
      'delivery_address': 'عنوان التوصيل',
      'payment': 'الدفع',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'top_sellers': 'الأكثر مبيعاً',
      'all_products': 'جميع المنتجات',
      'add_to_cart': 'أضف إلى السلة',
      'checkout': 'إتمام الشراء',
      'total': 'الإجمالي',
      'driver_mode': 'وضع السائق',
      'accept_order': 'قبول الطلب',
      'live_tracking': 'تتبع مباشر',
      'settings': 'الإعدادات',
      'dark_mode': 'الوضع الليلي',
      'language': 'اللغة',
      'orders_history': 'سجل الطلبات',
    },
  };

  String tr(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get t => Localizations.of<AppLocalizations>(this, AppLocalizations)!;
}
