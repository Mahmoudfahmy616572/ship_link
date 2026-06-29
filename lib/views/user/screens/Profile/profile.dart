import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/providers.dart';
import 'package:ship_link/services/profile_image_service.dart';
import 'package:ship_link/services/referral_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/notification_screen.dart';
import 'package:ship_link/views/user/screens/address_book/address_book_screen.dart';
import 'package:ship_link/views/user/screens/edit_profile/edit_profile_screen.dart';
import 'package:ship_link/views/user/screens/chat/chat_screen.dart';
import 'package:ship_link/views/user/screens/delivered/delivered.dart';
import 'package:ship_link/views/user/screens/orders/order_history.dart';
import 'package:ship_link/views/user/screens/security/security_screen.dart';
import 'package:ship_link/views/user/screens/splash/splash_screen.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  static String routName = '/Profile';

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final name = user?.userMetadata?['full_name'] as String? ??
        email.split('@').firstOrNull ??
        'User';
    final phone = user?.phone ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.t.tr('my_profile'),
          style: appStyle(22, FontWeight.w700, AppColors.textPrimary),
        ),
        actions: [
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, NotificationScreen.routName),
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: SvgPicture.asset(
                'assets/icons/NotificationBell.svg',
                height: 24.h,
                width: 24.w,
                color: AppColors.headerIcons,
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            _ProfileCard(name: name, email: email, phone: phone),
            SizedBox(height: 16.h),
            _StatsCard(),
            SizedBox(height: 20.h),
            _ReferralCard(),
            SizedBox(height: 20.h),
            _MyOrders(),
            SizedBox(height: 20.h),
            _AccountSettings(),
            SizedBox(height: 20.h),
            _SupportSection(),
            SizedBox(height: 20.h),
            _LogoutButton(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  const _ProfileCard(
      {required this.name, required this.email, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFF8A3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          _ProfileAvatar(name: name),
          SizedBox(height: 12.h),
          Text(
            name,
            style: appStyle(24, FontWeight.w700, Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            style: appStyle(14, FontWeight.w400, Colors.white.withAlpha(220)),
          ),
          if (phone.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              phone,
              style: appStyle(14, FontWeight.w400, Colors.white.withAlpha(220)),
            ),
          ],
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, EditProfileScreen.routName),
            child: Container(
              height: 40.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  context.t.tr('edit_profile'),
                  style: appStyle(14, FontWeight.w600, AppColors.cta),
                ),
              ),
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

class _StatsCardState extends State<_StatsCard> {
  Future<Map<String, int>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<Map<String, int>> _loadStats() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return {'orders': 0, 'reward_points': 0};

    final orders = await Supabase.instance.client
        .from('orders')
        .select('total_price')
        .eq('user_id', userId);

    final totalPoints = orders.fold<int>(
        0, (sum, o) => sum + (((o['total_price'] as num?)?.toInt() ?? 0) ~/ 10));

    return {'orders': orders.length, 'reward_points': totalPoints};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'orders': 0, 'reward_points': 0};
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withAlpha(8),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${data['orders']}',
                      style: appStyle(28, FontWeight.w700, AppColors.cta),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      context.t.tr('orders'),
                      style: appStyle(13, FontWeight.w500, AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: AppColors.border,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${data['reward_points']}',
                      style: appStyle(28, FontWeight.w700, AppColors.primary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      context.t.tr('reward_points'),
                      style: appStyle(13, FontWeight.w500, AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          _OrderStatus(context.t.tr('pending'), Icons.hourglass_empty, AppColors.warning,
              counts['pending'] ?? 0),
          _OrderStatus(context.t.tr('shipped'), Icons.local_shipping, AppColors.primary,
              counts['shipped'] ?? 0),
          _OrderStatus(context.t.tr('in_transit'), Icons.flight_takeoff, AppColors.info,
              counts['in_transit'] ?? 0),
          _OrderStatus(context.t.tr('delivered'), Icons.check_circle, AppColors.success,
              counts['delivered'] ?? 0),
          _OrderStatus(context.t.tr('cancelled'), Icons.cancel, AppColors.error,
              counts['cancelled'] ?? 0),
        ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, OrderHistory.routName),
                child: Row(
                  children: [
                    Text(
                      context.t.tr('my_orders'),
                      style: appStyle(18, FontWeight.w700, AppColors.textPrimary),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 20.sp, color: AppColors.textHint),
                  ],
                ),
              ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 110.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statuses.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final s = statuses[i];
                  final statusKeys = ['pending', 'shipped', 'in_transit', 'delivered', 'cancelled'];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      Delivered.routName,
                      arguments: statusKeys[i],
                    ),
                    child: SizedBox(
                      width: 100.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(s.icon, color: s.color, size: 24.r),
                            SizedBox(height: 6.h),
                            Flexible(
                              child: Text(
                                s.title,
                                style: appStyle(11, FontWeight.w500, AppColors.textPrimary),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${s.count}',
                              style: appStyle(18, FontWeight.w700, s.color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OrderStatus {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  const _OrderStatus(this.title, this.icon, this.color, this.count);
}

class _AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingItem(
        context.t.tr('address_book'),
        Icons.location_on_outlined,
        onTap: () =>
            Navigator.pushNamed(context, AddressBookScreen.routName),
      ),
      _SettingItem(
        context.t.tr('payment_methods'),
        Icons.credit_card_outlined,
      ),
      _SettingItem(
        context.t.tr('notifications'),
        Icons.notifications_outlined,
        onTap: () =>
            Navigator.pushNamed(context, NotificationScreen.routName),
      ),
      _SettingItem(
        context.t.tr('security'),
        Icons.shield_outlined,
        onTap: () =>
            Navigator.pushNamed(context, SecurityScreen.routName),
      ),
      _SettingItem(
        context.t.tr('language'),
        Icons.language_outlined,
        onTap: () => _showLanguageDialog(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.tr('account_settings'),
          style: appStyle(18, FontWeight.w700, AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, size: 22.r, color: AppColors.cta),
                    title: Text(
                      item.label,
                      style: appStyle(15, FontWeight.w500, AppColors.textPrimary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 22.r,
                      color: AppColors.textHint,
                    ),
                    onTap: item.onTap,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.only(left: 54.w),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final locale = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.tr('language'), style: appStyle(18, FontWeight.w600, AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.t.tr('english'), style: appStyle(16, FontWeight.w500, AppColors.textPrimary)),
              leading: Radio<String>(
                value: 'en',
                groupValue: locale.locale.languageCode,
                activeColor: AppColors.cta,
                onChanged: (_) {
                  locale.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
            ),
            ListTile(
              title: Text('العربية', style: appStyle(16, FontWeight.w500, AppColors.textPrimary)),
              leading: Radio<String>(
                value: 'ar',
                groupValue: locale.locale.languageCode,
                activeColor: AppColors.cta,
                onChanged: (_) {
                  locale.setLocale(const Locale('ar'));
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.tr('support'),
          style: appStyle(18, FontWeight.w700, AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            children: [
              _supportTile(context, context.t.tr('help_center'), Icons.help_outline, () {}),
              _divider(),
              _supportTile(context, context.t.tr('contact_us'), Icons.mail_outline, () => Navigator.pushNamed(context, Chat.routName)),
              _divider(),
              _supportTile(context, context.t.tr('about_shiplink'), Icons.info_outline, () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _supportTile(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22.r, color: AppColors.textPrimary),
      title: Text(
        label,
        style: appStyle(15, FontWeight.w500, AppColors.textPrimary),
      ),
      trailing: Icon(Icons.chevron_right, size: 22.r, color: AppColors.textHint),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.only(left: 54.w),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
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
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: AppColors.cta, size: 20.sp),
              SizedBox(width: 8.w),
              Text(context.t.tr('referral_code'),
                  style: appStyle(16, FontWeight.w600, AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: 10.h),
          if (_loading)
            SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          else ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _code ?? '',
                      style: appStyle(20, FontWeight.w700, AppColors.cta).copyWith(letterSpacing: 2),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    if (_code != null) {
                      SharePlus.instance.share(ShareParams(text: ReferralService().shareText(_code!)));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.cta,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.share, color: Colors.white, size: 20.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(context.t.tr('share_code_description'),
                style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
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
                  child: Text(
                    context.t.tr('log_out'),
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.t.tr('logout_successful')),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                  context, Splash.routName, (route) => false);
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.cta, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          context.t.tr('log_out'),
          style: appStyle(16, FontWeight.w600, AppColors.cta),
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

  void _pickImage(ImageSource source) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final svc = ProfileImageService();
    final file = source == ImageSource.gallery
        ? await svc.pickFromGallery()
        : await svc.pickFromCamera();
    if (file == null) return;
    try {
      final url = await svc.upload(userId, file);
      if (!mounted) return;
      await Supabase.instance.client
          .from('profiles')
          .upsert({'id': userId, 'avatar_url': url});
      setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.t.tr('choose_from_gallery')),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.t.tr('take_a_photo')),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48.r,
            backgroundColor: Colors.white.withAlpha(40),
            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _avatarUrl!,
                      width: 96.r,
                      height: 96.r,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Center(
                        child: Text(
                          widget.name[0].toUpperCase(),
                          style: appStyle(36, FontWeight.w700, Colors.white),
                        ),
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
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.camera_alt, size: 18.sp, color: AppColors.cta),
            ),
          ),
        ],
      ),
    );
  }
}
