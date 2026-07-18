import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/login/admin_login_web.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_side_nav.dart';
import 'package:ship_link/web/admin/presentation/screens/dashboard/admin_dashboard_web.dart';
import 'package:ship_link/web/admin/presentation/screens/users/admin_users_web.dart';
import 'package:ship_link/web/admin/presentation/screens/drivers/admin_drivers_web.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/admin_orders_web.dart';

// ده الـ shell بتاع الأدمن، جواه السايد بار والـ body بيتغير حسب الشاشة المختارة
class AdminScaffoldWeb extends StatefulWidget {
  const AdminScaffoldWeb({super.key});
  static String routName = '/admin';

  @override
  State<AdminScaffoldWeb> createState() => _AdminScaffoldWebState();
}

class _AdminScaffoldWebState extends State<AdminScaffoldWeb> {
  int _selected = 0;

  // عناصر التنقل في السايد بار
  static const _nav = [
    (Icons.dashboard_rounded, 'dashboard'),
    (Icons.people_alt_rounded, 'users'),
    (Icons.local_shipping_rounded, 'drivers'),
    (Icons.receipt_long_rounded, 'orders'),
  ];

  // الشاشات الأربعة بتوع اللوحة
  final List<Widget> _pages = const [
    AdminDashboardWeb(),
    AdminUsersWeb(),
    AdminDriversWeb(),
    AdminOrdersWeb(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final t = context.t;

    return BlocBuilder<AdminAuthCubit, dynamic>(
      builder: (context, state) {
        // لو مش مسجل دخول أدمن، حوله على صفحة اللوجين
        if (state is AdminAuthFailure || state is AdminSignedOut || state is AdminAuthInitial) {
          return const _AdminLoginRedirect();
        }
        final admin = (AdminAuthCubit.get(context).state is AdminAuthSuccess)
            ? (AdminAuthCubit.get(context).state as AdminAuthSuccess).admin
            : (AdminAuthCubit.get(context).state is AdminAuthRestored)
                ? (AdminAuthCubit.get(context).state as AdminAuthRestored).admin
                : <String, dynamic>{};
        final navItems = _nav.map((e) => NavItem(e.$1, t.tr(e.$2))).toList();
        final titles = [t.tr('dashboard'), t.tr('users'), t.tr('drivers'), t.tr('orders')];

        return isWide
            ? Row(
                children: [
                  AdminSideNav(
                    selectedIndex: _selected,
                    items: navItems,
                    onTap: (i) => setState(() => _selected = i),
                    userName: admin['full_name']?.toString() ?? admin['email']?.toString() ?? '',
                  ),
                  Expanded(child: _buildBody(titles)),
                ],
              )
            : _buildNarrow(navItems, titles);
      },
    );
  }

  // جسم الشاشة للوضع العريض
  Widget _buildBody(List<String> titles) {
    return Scaffold(
      appBar: _buildAppBar(titles[_selected]),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(key: ValueKey(_selected), child: _pages[_selected]),
      ),
    );
  }

  // نسخة الموبايل بتبقى بـ bottom nav
  Widget _buildNarrow(List<NavItem> navItems, List<String> titles) {
    return Scaffold(
      appBar: _buildAppBar(titles[_selected]),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(key: ValueKey(_selected), child: _pages[_selected]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        onTap: (i) => setState(() => _selected = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        items: navItems
            .map((e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.label))
            .toList(),
      ),
    );
  }

  // البار العلوي فيه زر تسجيل الخروج
  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0.5,
      title: Text(title, style: appStyle(18, FontWeight.w600, AppColors.textPrimary)),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
          onPressed: () {
            context.read<AdminAuthCubit>().signOut();
            Navigator.pushReplacementNamed(context, AdminLoginWeb.routName);
          },
        ),
      ],
    );
  }
}

// لو مفيش أدمن متسجل، نحوله على اللوجين فوراً
class _AdminLoginRedirect extends StatelessWidget {
  const _AdminLoginRedirect();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.pushReplacementNamed(context, AdminLoginWeb.routName);
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
