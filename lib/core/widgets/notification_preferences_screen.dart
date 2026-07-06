import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/services/notification_preferences_service.dart';
import 'package:ship_link/core/utils/sizer.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final _service = NotificationPreferencesService();
  final ValueNotifier<NotificationPreferences> _prefs = ValueNotifier(const NotificationPreferences());
  final ValueNotifier<bool> _loading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _prefs.value = _service.cached;
    _load();
  }

  Future<void> _load() async {
    final p = await _service.load();
    _prefs.value = p;
    _loading.value = false;
  }

  Future<void> _update(NotificationPreferences p) async {
    _prefs.value = p;
    await _service.save(p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('notification_preferences')),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (context, loading, _) {
          if (loading) return const Center(child: CircularProgressIndicator());
          return ValueListenableBuilder<NotificationPreferences>(
            valueListenable: _prefs,
            builder: (context, prefs, _) {
              return ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Card(
                    child: Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        title: Text(context.t.tr('order_updates')),
                        value: prefs.orderUpdates,
                        onChanged: (v) => _update(NotificationPreferences(
                          orderUpdates: v,
                          chatMessages: prefs.chatMessages,
                          promotions: prefs.promotions,
                        )),
                      ),
                    ),
                  ),
                  Card(
                    child: Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        title: Text(context.t.tr('chat_messages')),
                        value: prefs.chatMessages,
                        onChanged: (v) => _update(NotificationPreferences(
                          orderUpdates: prefs.orderUpdates,
                          chatMessages: v,
                          promotions: prefs.promotions,
                        )),
                      ),
                    ),
                  ),
                  Card(
                    child: Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        title: Text(context.t.tr('promotions')),
                        value: prefs.promotions,
                        onChanged: (v) => _update(NotificationPreferences(
                          orderUpdates: prefs.orderUpdates,
                          chatMessages: prefs.chatMessages,
                          promotions: v,
                        )),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
