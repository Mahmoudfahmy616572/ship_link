import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/providers.dart';
import 'package:ship_link/views/shared/notification_preferences_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static String routName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.tr('settings')),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: Text(t.tr('dark_mode')),
                value:
                    context.watch<ThemeProvider>().themeMode == ThemeMode.dark,
                onChanged: (_) {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text(t.tr('language')),
                trailing: Text(
                  context.watch<LocaleProvider>().locale.languageCode == 'en'
                      ? 'English'
                      : 'العربية',
                ),
                onTap: () {
                  context.read<LocaleProvider>().toggleLocale();
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(t.tr('notification_preferences')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
