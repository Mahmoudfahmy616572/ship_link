import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/providers.dart';
import 'package:ship_link/driver/routs_driver.dart';
import 'package:workmanager/workmanager.dart';

import 'package:ship_link/core/services/notification_service.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/driver/presentation/screens/Splash/driver_splash.dart';
import 'package:ship_link/core/widgets/set_new_password/set_new_password_screen.dart';

import 'package:ship_link/core/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  setupServeiceLocator();
  runApp(const DriverApp());
  // Heavy inits after first frame so native splash disappears quickly
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (_) {
    debugPrint('Firebase not configured - notifications disabled');
  }
  await Workmanager().registerPeriodicTask(
    'notif-poller',
    'checkNotifications',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return BlocProvider(
            create: (context) => AuthCubit(),
            child: BlocListener<AuthCubit, AuthState>(
              listenWhen: (prev, cur) => cur is PasswordRecoveryState,
              listener: (context, state) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SetNewPasswordScreen()),
                );
              },
              child: MaterialApp(
              scrollBehavior: _NoOverscrollBehavior(),
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
              locale: localeProvider.locale,
              localeListResolutionCallback: (locales, supportedLocales) {
                if (locales == null || locales.isEmpty) return const Locale('en');
                for (final locale in locales) {
                  for (final supported in supportedLocales) {
                    if (supported.languageCode == locale.languageCode) {
                      return supported;
                    }
                  }
                }
                return const Locale('en');
              },
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

class _NoOverscrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
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
