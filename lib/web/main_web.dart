import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/core/config.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/providers.dart';
import 'package:ship_link/web/presentation/services/auth_service_web.dart';
import 'package:ship_link/web/routs_web.dart';
import 'package:ship_link/web/presentation/layout/web_scaffold.dart';
import 'package:ship_link/core/utils/sizer.dart';
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

  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) {
          final auth = AuthServiceWeb();
          auth.initialize();
          return auth;
        }),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            navigatorKey: GlobalKey<NavigatorState>(),
            title: 'ShipLink',
            builder: (context, child) {
              Sizer.init(context);
              return child ?? const SizedBox.shrink();
            },
            onGenerateRoute: onGenerateWebRoute,
            initialRoute: WebScaffold.routName,
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
    );
  }
}
