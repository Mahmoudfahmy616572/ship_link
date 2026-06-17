import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/providers.dart';

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
        padding: const EdgeInsets.all(16),
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
          ],
        ),
      ),
    );
  }
}
