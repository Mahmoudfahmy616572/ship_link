import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/services/notification_preferences_service.dart';
import 'package:ship_link/utils/sizer.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final _service = NotificationPreferencesService();
  late NotificationPreferences _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prefs = _service.cached;
    _load();
  }

  Future<void> _load() async {
    final p = await _service.load();
    if (mounted) setState(() { _prefs = p; _loading = false; });
  }

  Future<void> _update(NotificationPreferences p) async {
    setState(() => _prefs = p);
    await _service.save(p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('notification_preferences')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Card(
                  child: Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      title: Text(context.t.tr('order_updates')),
                      value: _prefs.orderUpdates,
                      onChanged: (v) => _update(NotificationPreferences(
                        orderUpdates: v,
                        chatMessages: _prefs.chatMessages,
                        promotions: _prefs.promotions,
                      )),
                    ),
                  ),
                ),
                Card(
                  child: Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      title: Text(context.t.tr('chat_messages')),
                      value: _prefs.chatMessages,
                      onChanged: (v) => _update(NotificationPreferences(
                        orderUpdates: _prefs.orderUpdates,
                        chatMessages: v,
                        promotions: _prefs.promotions,
                      )),
                    ),
                  ),
                ),
                Card(
                  child: Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      title: Text(context.t.tr('promotions')),
                      value: _prefs.promotions,
                      onChanged: (v) => _update(NotificationPreferences(
                        orderUpdates: _prefs.orderUpdates,
                        chatMessages: _prefs.chatMessages,
                        promotions: v,
                      )),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
