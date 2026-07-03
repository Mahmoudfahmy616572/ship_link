import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/providers.dart';
import 'package:ship_link/routs.dart';
import 'package:ship_link/services/notification_service.dart';
import 'package:ship_link/services/supabase_service.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    debugPrint('Firebase core init failed');
  }
  await NotificationService().initialize();
  setupServeiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            child: MaterialApp(
              navigatorKey: NotificationService.navigatorKey,
              title: 'ShipLink',
              onGenerateRoute: onGenerateRoute,
              initialRoute: Splash.routName,
              onUnknownRoute: (settings) => SlowMaterialPageRoute(
                builder: (_) => const Splash(),
                settings: settings,
              ),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                brightness: Brightness.light,
                colorSchemeSeed: AppColors.primary,
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: _TopToBottomTransitionBuilder(),
                    TargetPlatform.iOS: _TopToBottomTransitionBuilder(),
                  },
                ),
              ),
              locale: localeProvider.locale,
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) return const Locale('en');
                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
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
          );
        },
      ),
    );
  }
}

class _TopToBottomTransitionBuilder extends PageTransitionsBuilder {
  const _TopToBottomTransitionBuilder();

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
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}
