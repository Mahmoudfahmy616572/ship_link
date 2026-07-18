import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/core/config.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/providers.dart';
import 'package:ship_link/web/routs_web.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/data/services_locators.dart';
import 'package:ship_link/web/presentation/screens/splash/splash_web.dart';
import 'package:ship_link/web/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/web/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/web/presentation/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/web/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/web/presentation/cubits/orderHistory/order_history_cubit.dart';
import 'package:ship_link/web/presentation/cubits/payment/payment_cubit.dart';
import 'package:ship_link/web/presentation/cubits/chats/chat_list_cubit.dart';
import 'package:ship_link/web/presentation/cubits/chats/support_chat_cubit.dart';
import 'package:ship_link/web/presentation/cubits/homeFilter/home_filter_cubit.dart';
import 'package:ship_link/web/presentation/cubits/notification/notification_cubit.dart';
import 'package:ship_link/web/presentation/cubits/search/search_cubit.dart';
import 'package:ship_link/web/presentation/cubits/address/address_cubit.dart';
import 'package:ship_link/web/presentation/cubits/profileEdit/profile_edit_cubit.dart';
import 'package:ship_link/web/presentation/cubits/checkout/checkout_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/dashboard/admin_dashboard_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/login/admin_login_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  setupWebServiceLocator();

  // لو دخل على مسار الأدمن، نتأكد من الـ session المحفوظ قبل ما الصفحات تفتح
  final adminCubit = getIt<AdminAuthCubit>();
  if ((html.window.location.pathname ?? '').contains('admin')) {
    adminCubit.checkSession();
  }

  runApp(const WebApp());
}

final _navigatorKey = GlobalKey<NavigatorState>();

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
          BlocProvider<AddToCartCubit>(create: (_) => getIt<AddToCartCubit>()),
          BlocProvider<ConfirmCartCubit>(create: (_) => getIt<ConfirmCartCubit>()),
          BlocProvider<FavouriteCubit>(create: (_) => getIt<FavouriteCubit>()),
          BlocProvider<GetAllProuductsCubit>(create: (_) => getIt<GetAllProuductsCubit>()),
          BlocProvider<GetFromCartCubit>(create: (_) => getIt<GetFromCartCubit>()),
          BlocProvider<GetTopSellerCubit>(create: (_) => getIt<GetTopSellerCubit>()),
          BlocProvider<OrderHistoryCubit>(create: (_) => getIt<OrderHistoryCubit>()),
          BlocProvider<PaymentCubit>(create: (_) => getIt<PaymentCubit>()),
          BlocProvider<ChatListCubit>(create: (_) => getIt<ChatListCubit>()),
          BlocProvider<SupportChatCubit>(create: (_) => getIt<SupportChatCubit>()),
          BlocProvider<HomeFilterCubit>(create: (_) => getIt<HomeFilterCubit>()),
          BlocProvider<NotificationCubit>(create: (_) => getIt<NotificationCubit>()),
          BlocProvider<SearchCubit>(create: (_) => getIt<SearchCubit>()),
          BlocProvider<AddressCubit>(create: (_) => getIt<AddressCubit>()),
          BlocProvider<ProfileEditCubit>(create: (_) => getIt<ProfileEditCubit>()),
          BlocProvider<CheckoutCubit>(create: (_) => getIt<CheckoutCubit>()),
          BlocProvider<AdminAuthCubit>(create: (_) => getIt<AdminAuthCubit>()),
          BlocProvider<AdminDashboardCubit>(create: (_) => getIt<AdminDashboardCubit>()),
          BlocProvider<AdminUsersCubit>(create: (_) => getIt<AdminUsersCubit>()),
          BlocProvider<AdminDriversCubit>(create: (_) => getIt<AdminDriversCubit>()),
          BlocProvider<AdminOrdersCubit>(create: (_) => getIt<AdminOrdersCubit>()),
        ],
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'ShipLink',
              builder: (context, child) {
                Sizer.init(context);
                return child ?? const SizedBox.shrink();
              },
              onGenerateRoute: onGenerateWebRoute,
              // لو المسار فيه admin نفتح لوجين الأدمن مباشرة، غير كده السبلاش العادي
              initialRoute: (html.window.location.pathname ?? '').contains('admin')
                  ? AdminLoginWeb.routName
                  : SplashWeb.routName,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                brightness: Brightness.light,
                colorSchemeSeed: AppColors.primary,
                useMaterial3: true,
              ),
              locale: localeProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
            );
          },
        ),
      ),
    );
  }
}
