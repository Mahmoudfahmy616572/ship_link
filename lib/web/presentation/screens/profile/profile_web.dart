import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/providers.dart';
import 'package:ship_link/web/presentation/services/auth_service_web.dart';
import 'package:ship_link/core/services/profile_image_service.dart';
import 'package:ship_link/core/services/referral_service.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/addresses/addresses_web.dart';
import 'package:ship_link/web/presentation/screens/orders/orders_web.dart';
import 'package:ship_link/web/presentation/screens/login/login_web.dart';
import 'package:ship_link/web/presentation/screens/profile/edit_profile_web.dart';
import 'package:ship_link/web/presentation/screens/settings/settings_web.dart';
import 'package:ship_link/web/presentation/screens/security/security_web.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileWeb extends StatelessWidget {
  const ProfileWeb({super.key});
  static String routName = '/profile';

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16.h),
            Text(context.t.tr('login_to_view_profile'),
                style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
            SizedBox(height: 16.h),
            HoverScale(
              onTap: () => Navigator.pushNamed(context, LoginWeb.routName),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, LoginWeb.routName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(context.t.tr('sign_in')),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _ProfileCard(),
          SizedBox(height: 16),
          _StatsCard(),
          SizedBox(height: 16),
          _ReferralCard(),
          SizedBox(height: 20),
          _buildSectionTitle(context, context.t.tr('my_orders')),
          SizedBox(height: 12),
          _MyOrders(),
          SizedBox(height: 20),
          _buildSectionTitle(context, context.t.tr('account_settings')),
          SizedBox(height: 12),
          _AccountSettings(),
          SizedBox(height: 20),
          _buildSectionTitle(context, context.t.tr('support')),
          SizedBox(height: 12),
          _SupportSection(),
          SizedBox(height: 20),
          _LogoutButton(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(title, style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final name = user?.userMetadata?['full_name'] as String? ?? email.split('@').firstOrNull ?? 'User';
    final phone = user?.phone ?? '';

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFFF8A3D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _ProfileAvatar(name: name),
            SizedBox(height: 12),
            Text(name, style: appStyle(24, FontWeight.w700, Colors.white)),
            SizedBox(height: 4),
            Text(email, style: appStyle(14, FontWeight.w400, Colors.white70)),
            if (phone.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(phone, style: appStyle(14, FontWeight.w400, Colors.white70)),
            ],
            SizedBox(height: 16),
            HoverScale(
              scale: 1.02,
              onTap: () => Navigator.pushNamed(context, EditProfileWeb.routName),
              child: Container(
                height: 40,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(context.t.tr('edit_profile'),
                      style: appStyle(14, FontWeight.w600, AppColors.cta)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  final String name;
  const _ProfileAvatar({required this.name});

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final data = await Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();
    if (data != null && mounted) {
      setState(() => _avatarUrl = data['avatar_url'] as String?);
    }
  }

  void _pickImage() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;
    try {
      final svc = ProfileImageService();
      final url = await svc.upload(userId, file);
      if (!mounted) return;
      await Supabase.instance.client.from('profiles').upsert({'id': userId, 'avatar_url': url});
      setState(() => _avatarUrl = url);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white.withValues(alpha: 0.4),
            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      _avatarUrl!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        widget.name[0].toUpperCase(),
                        style: appStyle(36, FontWeight.w700, Colors.white),
                      ),
                    ),
                  )
                : Text(
                    widget.name[0].toUpperCase(),
                    style: appStyle(36, FontWeight.w700, Colors.white),
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.camera_alt, size: 18, color: AppColors.cta),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatefulWidget {
  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> with SingleTickerProviderStateMixin {
  Future<Map<String, int>>? _statsFuture;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, int>> _loadStats() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return {'orders': 0, 'reward_points': 0};
    final orders = await Supabase.instance.client
        .from('orders')
        .select('total_price')
        .eq('user_id', userId);
    final totalPoints = orders.fold<int>(0, (sum, o) => sum + (((o['total_price'] as num?)?.toInt() ?? 0) ~/ 10));
    return {'orders': orders.length, 'reward_points': totalPoints};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'orders': 0, 'reward_points': 0};
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), child: child,
          )),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(child: _statItem(context, '${data['orders']}', context.t.tr('orders'), AppColors.cta)),
                Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                Expanded(child: _statItem(context, '${data['reward_points']}', context.t.tr('reward_points'), AppColors.primary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statItem(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: double.parse(value != '0' ? value : '0').toDouble()),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, val, _) => Text(
            val.toInt().toString(),
            style: appStyle(28, FontWeight.w700, color),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: appStyle(13, FontWeight.w500, const Color(0xFF6B7280))),
      ],
    );
  }
}

class _ReferralCard extends StatefulWidget {
  @override
  State<_ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends State<_ReferralCard> {
  String? _code;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final svc = ReferralService();
    final code = await svc.ensureCode(userId);
    if (mounted) setState(() { _code = code; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)), child: child,
      )),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: AppColors.cta, size: 20),
                SizedBox(width: 8),
                Text(context.t.tr('referral_code'),
                    style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
              ],
            ),
            SizedBox(height: 10),
            if (_loading)
              SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _code ?? '', style: appStyle(20, FontWeight.w700, AppColors.cta).copyWith(letterSpacing: 2),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  HoverScale(
                    onTap: () {
                      if (_code != null) {
                        SharePlus.instance.share(ShareParams(
                          text: ReferralService().shareText(_code!),
                        ));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cta,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.share, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(context.t.tr('share_code_description'),
                  style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280))),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyOrders extends StatefulWidget {
  @override
  State<_MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<_MyOrders> {
  Future<Map<String, int>>? _countsFuture;

  @override
  void initState() {
    super.initState();
    _countsFuture = _loadCounts();
  }

  Future<Map<String, int>> _loadCounts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return {};
    final orders = await Supabase.instance.client
        .from('orders')
        .select('status')
        .eq('user_id', userId);
    final counts = <String, int>{};
    for (final o in orders) {
      final status = (o['status'] as String?)?.toLowerCase() ?? '';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _countsFuture,
      builder: (context, snapshot) {
        final counts = snapshot.data ?? {};
        final statuses = [
          _statusItem(context, context.t.tr('pending'), Icons.hourglass_empty, const Color(0xFFF59E0B), counts['pending'] ?? 0),
          _statusItem(context, context.t.tr('shipped'), Icons.local_shipping, AppColors.primary, counts['shipped'] ?? 0),
          _statusItem(context, context.t.tr('in_transit'), Icons.flight_takeoff, const Color(0xFF3B82F6), counts['in_transit'] ?? 0),
          _statusItem(context, context.t.tr('delivered'), Icons.check_circle, AppColors.success, counts['delivered'] ?? 0),
          _statusItem(context, context.t.tr('cancelled'), Icons.cancel, AppColors.error, counts['cancelled'] ?? 0),
        ];
        return SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: statuses.length,
            separatorBuilder: (_, __) => SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = statuses[i];
              final statusKeys = ['pending', 'shipped', 'in_transit', 'delivered', 'cancelled'];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (i * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)), child: child,
                )),
                child: HoverScale(
                  scale: 1.05,
                  onTap: () => Navigator.pushNamed(context, OrdersWeb.routName),
                  child: Container(
                    width: 100,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, color: s.color, size: 24),
                        SizedBox(height: 6),
                        Flexible(
                          child: Text(s.title, style: appStyle(11, FontWeight.w500, const Color(0xFF111827)),
                              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(height: 2),
                        Text('${s.count}', style: appStyle(18, FontWeight.w700, s.color)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  _StatusItem _statusItem(BuildContext context, String title, IconData icon, Color color, int count) {
    return _StatusItem(title, icon, color, count);
  }
}

class _StatusItem {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  const _StatusItem(this.title, this.icon, this.color, this.count);
}

class _AccountSettings extends StatelessWidget {
  const _AccountSettings();

  void _showLanguageDialog(BuildContext context) {
    final locale = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.tr('language'), style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.t.tr('english'), style: appStyle(16, FontWeight.w500, const Color(0xFF111827))),
              leading: Radio<String>(
                value: 'en',
                groupValue: locale.locale.languageCode,
                activeColor: AppColors.cta,
                onChanged: (_) { locale.setLocale(const Locale('en')); Navigator.pop(ctx); },
              ),
            ),
            ListTile(
              title: Text('العربية', style: appStyle(16, FontWeight.w500, const Color(0xFF111827))),
              leading: Radio<String>(
                value: 'ar',
                groupValue: locale.locale.languageCode,
                activeColor: AppColors.cta,
                onChanged: (_) { locale.setLocale(const Locale('ar')); Navigator.pop(ctx); },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingItem(context.t.tr('address_book'), Icons.location_on_outlined,
          onTap: () => Navigator.pushNamed(context, AddressesWeb.routName)),
      _SettingItem(context.t.tr('payment_methods'), Icons.credit_card_outlined,
          onTap: () => Navigator.pushNamed(context, '/paymentMethods')),
      _SettingItem(context.t.tr('notifications'), Icons.notifications_outlined,
          onTap: () => Navigator.pushNamed(context, SettingsWeb.routName)),
      _SettingItem(context.t.tr('security'), Icons.shield_outlined,
          onTap: () => Navigator.pushNamed(context, SecurityWeb.routName)),
      _SettingItem(context.t.tr('language'), Icons.language_outlined,
          onTap: () => _showLanguageDialog(context)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;
            return Column(
              children: [
                HoverScale(
                  scale: 1.01,
                  onTap: item.onTap,
                  child: ListTile(
                    leading: Icon(item.icon, size: 22, color: AppColors.cta),
                    title: Text(item.label, style: appStyle(15, FontWeight.w500, const Color(0xFF111827))),
                    trailing: Icon(Icons.chevron_right, size: 22, color: const Color(0xFF9CA3AF)),
                    onTap: item.onTap,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.only(left: 54),
                    child: Divider(height: 1, thickness: 1, color: const Color(0xFFE5E7EB)),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SettingItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _SettingItem(this.label, this.icon, {this.onTap});
}

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            _tile(context, context.t.tr('help_center'), Icons.help_outline, () {}),
            _divider(),
            _tile(context, context.t.tr('contact_us'), Icons.mail_outline, () {}),
            _divider(),
            _tile(context, context.t.tr('about_shiplink'), Icons.info_outline, () {}),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return HoverScale(
      scale: 1.01,
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, size: 22, color: const Color(0xFF6B7280)),
        title: Text(label, style: appStyle(15, FontWeight.w500, const Color(0xFF111827))),
        trailing: Icon(Icons.chevron_right, size: 22, color: const Color(0xFF9CA3AF)),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.only(left: 54),
      child: Divider(height: 1, thickness: 1, color: const Color(0xFFE5E7EB)),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.t.tr('log_out')),
              content: Text(context.t.tr('are_you_sure_logout')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(context.t.tr('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(context.t.tr('log_out'), style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await context.read<AuthServiceWeb>().signOut();
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.cta, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(context.t.tr('log_out'), style: appStyle(16, FontWeight.w600, AppColors.cta)),
      ),
    );
  }
}
