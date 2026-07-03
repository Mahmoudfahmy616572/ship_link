import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/services/auth_service_web.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/web/shared/hover_widget.dart';

class SecurityWeb extends StatefulWidget {
  const SecurityWeb({super.key});
  static String routName = '/security';

  @override
  State<SecurityWeb> createState() => _SecurityWebState();
}

class _SecurityWebState extends State<SecurityWeb> with SingleTickerProviderStateMixin {
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

  void _showChangePasswordDialog() {
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.tr('change_password'), style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
        content: TextField(
          controller: newCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: context.t.tr('new_password'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
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
        title: Text(context.t.tr('security')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _card(context, [
              _tile(context, context.t.tr('change_password'), Icons.lock_outlined, _showChangePasswordDialog),
              const _Divider(),
              _tile(context, context.t.tr('two_factor_auth'), Icons.verified_user_outlined, null),
              const _Divider(),
              _tile(context, context.t.tr('active_sessions'), Icons.devices_outlined, null),
            ]),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: AppColors.cta, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.t.tr('security_tips'),
                      style: appStyle(13, FontWeight.w400, const Color(0xFF9A3412)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(type: MaterialType.transparency, child: Column(children: children)),
    );
  }

  Widget _tile(BuildContext context, String label, IconData icon, VoidCallback? onTap) {
    return HoverScale(
      scale: 1.01,
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, size: 22, color: AppColors.cta),
        title: Text(label, style: appStyle(15, FontWeight.w500, const Color(0xFF111827))),
        trailing: Icon(Icons.chevron_right, size: 22, color: const Color(0xFF9CA3AF)),
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
