import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/providers.dart';
import 'package:ship_link/web/presentation/services/auth_service_web.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsWeb extends StatefulWidget {
  const SettingsWeb({super.key});
  static String routName = '/settings';

  @override
  State<SettingsWeb> createState() => _SettingsWebState();
}

class _SettingsWebState extends State<SettingsWeb> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    final locale = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.tr('language'), style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text(context.t.tr('english'), style: appStyle(16, FontWeight.w500, const Color(0xFF111827))),
            leading: Radio<String>(
              value: 'en', groupValue: locale.locale.languageCode, activeColor: AppColors.cta,
              onChanged: (_) { locale.setLocale(const Locale('en')); Navigator.pop(ctx); },
            ),
          ),
          ListTile(
            title: Text('العربية', style: appStyle(16, FontWeight.w500, const Color(0xFF111827))),
            leading: Radio<String>(
              value: 'ar', groupValue: locale.locale.languageCode, activeColor: AppColors.cta,
              onChanged: (_) { locale.setLocale(const Locale('ar')); Navigator.pop(ctx); },
            ),
          ),
        ]),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.tr('change_password'), style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: oldCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.t.tr('current_password'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: newCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.t.tr('new_password'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.t.tr('cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (newCtrl.text.length < 6) return;
              await context.read<AuthServiceWeb>().updatePassword(newCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t.tr('password_updated'))),
                );
              }
            },
            child: Text(context.t.tr('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('settings')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _sectionTitle(context, context.t.tr('general')),
            SizedBox(height: 8),
            _card([
              _tile(context, context.t.tr('language'), Icons.language_outlined, _showLanguageDialog),
              const _Divider(),
              _tile(context, context.t.tr('change_password'), Icons.lock_outlined, _showChangePasswordDialog),
            ]),
            SizedBox(height: 24),
            _sectionTitle(context, context.t.tr('notifications')),
            SizedBox(height: 8),
            _card([
              _tile(context, context.t.tr('order_updates'), Icons.inventory_2_outlined, null, trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              )),
              const _Divider(),
              _tile(context, context.t.tr('chat_messages'), Icons.chat_outlined, null, trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              )),
              const _Divider(),
              _tile(context, context.t.tr('promotions'), Icons.discount_outlined, null, trailing: Switch(
                value: false,
                onChanged: (_) {},
              )),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: appStyle(16, FontWeight.w700, const Color(0xFF111827)));
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(type: MaterialType.transparency, child: Column(children: children)),
    );
  }

  Widget _tile(BuildContext context, String label, IconData icon, VoidCallback? onTap, {Widget? trailing}) {
    return HoverScale(
      scale: 1.01,
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, size: 22, color: AppColors.cta),
        title: Text(label, style: appStyle(15, FontWeight.w500, const Color(0xFF111827))),
        trailing: trailing ?? Icon(Icons.chevron_right, size: 22, color: const Color(0xFF9CA3AF)),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 54),
      child: Divider(height: 1, thickness: 1, color: const Color(0xFFE5E7EB)),
    );
  }
}
