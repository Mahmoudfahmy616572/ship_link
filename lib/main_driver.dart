import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/providers.dart';
import 'package:ship_link/routs_driver.dart';
import 'package:ship_link/services/notification_service.dart';
import 'package:ship_link/services/supabase_service.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/driver/screens/Splash/driver_splash.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (_) {
    debugPrint('Firebase not configured - notifications disabled');
  }
  setupServeiceLocator();
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return BlocProvider(
            create: (context) => AuthCubit(),
            child: MaterialApp(
              navigatorKey: NotificationService.navigatorKey,
              title: 'ShipLink - Driver',
              builder: (context, child) {
                Sizer.init(context);
                return child!;
              },
              onGenerateRoute: onGenerateDriverRoute,
              initialRoute: DriverSplash.routName,
              onUnknownRoute: (settings) => DriverSlowRoute(
                builder: (_) => const DriverSplash(),
                settings: settings,
              ),
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                colorSchemeSeed: const Color(0xFF242424),
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: _DriverTransitionBuilder(),
                    TargetPlatform.iOS: _DriverTransitionBuilder(),
                  },
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorSchemeSeed: const Color(0xFF242424),
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: _DriverTransitionBuilder(),
                    TargetPlatform.iOS: _DriverTransitionBuilder(),
                  },
                ),
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
            ),
          );
        },
      ),
    );
  }
}

class _DriverTransitionBuilder extends PageTransitionsBuilder {
  const _DriverTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}
