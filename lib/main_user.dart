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
import 'package:ship_link/routs_user.dart';
import 'package:ship_link/services/notification_service.dart';
import 'package:ship_link/services/supabase_service.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';

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
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

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
              title: 'ShipLink - User',
              builder: (context, child) {
                Sizer.init(context);
                return child!;
              },
              onGenerateRoute: onGenerateUserRoute,
              initialRoute: Splash.routName,
              onUnknownRoute: (settings) => UserSlowRoute(
                builder: (_) => const Splash(),
                settings: settings,
              ),
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                colorSchemeSeed: AppColors.primary,
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: _UserTransitionBuilder(),
                    TargetPlatform.iOS: _UserTransitionBuilder(),
                  },
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorSchemeSeed: AppColors.primary,
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: _UserTransitionBuilder(),
                    TargetPlatform.iOS: _UserTransitionBuilder(),
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

class _UserTransitionBuilder extends PageTransitionsBuilder {
  const _UserTransitionBuilder();

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
