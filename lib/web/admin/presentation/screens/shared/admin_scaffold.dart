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
import 'package:ship_link/web/admin/presentation/screens/users/admin_user_detail_web.dart';
import 'package:ship_link/web/admin/presentation/screens/drivers/admin_drivers_web.dart';
import 'package:ship_link/web/admin/presentation/screens/drivers/admin_driver_detail_web.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/admin_orders_web.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/admin_order_detail_web.dart';
import 'package:ship_link/web/admin/presentation/screens/products/admin_products_web.dart';
import 'package:ship_link/web/admin/presentation/screens/products/admin_product_detail_web.dart';
import 'package:ship_link/web/admin/domain/models/admin_models.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_toast.dart';

// ده الـ shell بتاع الأدمن، جواه السايد بار والـ body بيتغير حسب الشاشة المختارة
class AdminScaffoldWeb extends StatefulWidget {
  const AdminScaffoldWeb({super.key});
  static String routName = '/admin';

  @override
  State<AdminScaffoldWeb> createState() => _AdminScaffoldWebState();
}

class _AdminScaffoldWebState extends State<AdminScaffoldWeb> {
  // بنتتبع تاريخ الشاشات عشان زرار الـ back يرجع للشاشة اللي قبلها جوه الأدمن
  final List<int> _history = [0];
  int get _selected => _history.last;

  // لو مفتوح تفاصيل أوردر، نخزن الـ id بتاعه (null = مش مفتوح)
  int? _detailOrderId;
  // لو مفتوح تفاصيل يوزر، نخزن الـ data بتاعته
  Map<String, dynamic>? _detailUser;
  // لو مفتوح تفاصيل درايفر
  Map<String, dynamic>? _detailDriver;
  // لو مفتوح تفاصيل منتج
  AdminProduct? _detailProduct;

  // عناصر التنقل في السايد بار
  static const _nav = [
    (Icons.dashboard_rounded, 'dashboard'),
    (Icons.people_alt_rounded, 'users'),
    (Icons.local_shipping_rounded, 'drivers'),
    (Icons.receipt_long_rounded, 'orders'),
    (Icons.inventory_2_rounded, 'products'),
  ];

  // الشاشات الأربعة بتوع اللوحة
  final List<Widget> _pages = const [
    AdminDashboardWeb(),
    AdminUsersWeb(),
    AdminDriversWeb(),
    AdminOrdersWeb(),
    AdminProductsWeb(),
  ];

  // لما نختار شاشة من السايد بار، نضيفها فوق التاريخ
  void _select(int i) {
    if (_detailOrderId != null) {
      // لو مفتوح تفاصيل، نقفله ونتحرك للشاشة الجديدة
      setState(() {
        _detailOrderId = null;
        if (_history.last != i) _history.add(i);
      });
      return;
    }
    if (_history.last == i) return;
    setState(() => _history.add(i));
  }

  // نفتح تفاصيل أوردر (جوه الـ scaffold مش Navigator.push)
  void _openOrderDetail(int orderId) {
    setState(() => _detailOrderId = orderId);
  }

  // نقفل تفاصيل الأوردر وندجع للـ orders list
  void _closeOrderDetail() {
    setState(() => _detailOrderId = null);
  }

  // نفتح تفاصيل يوزر
  void _openUserDetail(Map<String, dynamic> user) {
    setState(() => _detailUser = user);
  }

  // نقفل تفاصيل اليوزر
  void _closeUserDetail() {
    setState(() => _detailUser = null);
  }

  // نفتح تفاصيل درايفر
  void _openDriverDetail(Map<String, dynamic> driver) {
    setState(() => _detailDriver = driver);
  }

  // نقفل تفاصيل الدرايفر
  void _closeDriverDetail() {
    setState(() => _detailDriver = null);
  }

  // نفتح تفاصيل منتج
  void _openProductDetail(AdminProduct product) {
    setState(() => _detailProduct = product);
  }

  // نقفل تفاصيل المنتج
  void _closeProductDetail() {
    setState(() => _detailProduct = null);
  }

  // دي بتتعامل مع زرار الـ back بتاع المتصفح
  Future<bool> _onWillPop() async {
    // لو تفاصيل أوردر مفتوحة، نقفلها ونرجع للـ orders
    if (_detailOrderId != null) {
      setState(() => _detailOrderId = null);
      return false;
    }
    // لو تفاصيل يوزر مفتوحة، نقفلها ونرجع للـ users
    if (_detailUser != null) {
      setState(() => _detailUser = null);
      return false;
    }
    // لو تفاصيل درايفر مفتوحة، نقفلها ونرجع للـ drivers
    if (_detailDriver != null) {
      setState(() => _detailDriver = null);
      return false;
    }
    // لو تفاصيل منتج مفتوحة، نقفلها ونرجع للـ products
    if (_detailProduct != null) {
      setState(() => _detailProduct = null);
      return false;
    }
    // لو لسه فيه شاشات قبل كده، نرجع لـ واحدة قبلها
    if (_history.length > 1) {
      setState(() => _history.removeLast());
      return false; // منعنا الخروج من الأبلكيشن
    }
    // لو إحنا في أول شاشة (الـ Home)، منمنع الخروج للوجين/اليوزر أب
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final t = context.t;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: ValueListenableBuilder<bool>(
        valueListenable: AdminThemeMode.isDark,
        builder: (context, isDark, _) {
          return BlocBuilder<AdminAuthCubit, dynamic>(
            builder: (context, state) {
          // لو مش مسجل دخول أدمن، حوله على صفحة اللوجين
          // (من غير ما نحوّل وهو لسه بيتأكد من الـ session المحفوظ)
          if (state is AdminAuthFailure || state is AdminSignedOut || state is AdminAuthInitial) {
            return const _AdminLoginRedirect();
          }
          // وهو بيفحص السيشن نسيب اللوحة ظاهرة (أو نحط مؤشر تحميل)
          if (state is AdminAuthChecking) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final admin = (AdminAuthCubit.get(context).state is AdminAuthSuccess)
              ? (AdminAuthCubit.get(context).state as AdminAuthSuccess).admin
              : (AdminAuthCubit.get(context).state is AdminAuthRestored)
                  ? (AdminAuthCubit.get(context).state as AdminAuthRestored).admin
                  : <String, dynamic>{};
          final navItems = _nav.map((e) => NavItem(e.$1, t.tr(e.$2))).toList();
          final titles = [t.tr('dashboard'), t.tr('users'), t.tr('drivers'), t.tr('orders'), t.tr('products')];

          return isWide
              ? Row(
                  children: [
                    AdminSideNav(
                      selectedIndex: _selected,
                      items: navItems,
                      onTap: _select,
                      userName: admin['full_name']?.toString() ?? admin['email']?.toString() ?? '',
                      userRole: 'ROLE: ${admin['role']}',
                      isDark: isDark,
                    ),
                    Expanded(child: _buildBody(titles, isDark)),
                  ],
                )
              : _buildNarrow(navItems, titles, isDark);
            },
          );
        },
      ),
    );
  }

  // جسم الشاشة للوضع العريض
  Widget _buildBody(List<String> titles, bool isDark) {
    final child = _detailOrderId != null
        ? AdminOrderDetailWeb(
            orderId: _detailOrderId!,
            onBack: _closeOrderDetail,
            onOpenDetail: _openOrderDetail,
          )
        : _detailUser != null
            ? AdminUserDetailWeb(user: _detailUser!, onBack: _closeUserDetail)
                : _detailDriver != null
                    ? AdminDriverDetailWeb(
                        driver: _detailDriver!,
                        onBack: _closeDriverDetail,
                        onActivate: (d) {
                          // تفعيل الدرايفر
                          // (نستخدم الكيوبت عن طريق الـ context تحت)
                        },
                      )
                    : _detailProduct != null
                        ? AdminProductDetailWeb(
                            product: _detailProduct!,
                            onBack: _closeProductDetail,
                            onEdit: AdminAuthCubit.get(context).isSuperAdmin
                                ? (p) {
                                    _closeProductDetail();
                                    // نفتح فورم التعديل من شاشة المنتجات
                                  }
                                : null,
                          )
                        : _pages[_selected] is AdminOrdersWeb
                            ? AdminOrdersWeb(onOpenDetail: _openOrderDetail)
                            : _pages[_selected] is AdminUsersWeb
                                ? AdminUsersWeb(onOpen: _openUserDetail)
                                : _pages[_selected] is AdminDriversWeb
                                    ? AdminDriversWeb(onOpen: _openDriverDetail)
                                    : _pages[_selected] is AdminProductsWeb
                                        ? AdminProductsWeb(onOpen: _openProductDetail)
                                        : _pages[_selected];
    final title = _detailOrderId != null
        ? titles[3]
        : _detailUser != null
            ? titles[1]
            : _detailDriver != null
                ? titles[2]
                : _detailProduct != null
                    ? titles[4]
                    : titles[_selected];
    return Scaffold(
      backgroundColor: AdminThemeMode.bg(isDark),
      appBar: _buildAppBar(title, isDark),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey(_detailOrderId != null
              ? 'detail'
              : _detailUser != null
                  ? 'user'
                  : _detailDriver != null
                      ? 'driver'
                      : _selected),
          child: child,
        ),
      ),
    );
  }

  // نسخة الموبايل بتبقى بـ bottom nav
  Widget _buildNarrow(List<NavItem> navItems, List<String> titles, bool isDark) {
    final child = _detailOrderId != null
        ? AdminOrderDetailWeb(
            orderId: _detailOrderId!,
            onBack: _closeOrderDetail,
            onOpenDetail: _openOrderDetail,
          )
        : _detailUser != null
            ? AdminUserDetailWeb(user: _detailUser!, onBack: _closeUserDetail)
        : _detailDriver != null
            ? AdminDriverDetailWeb(
                driver: _detailDriver!,
                onBack: _closeDriverDetail,
              )
            : _detailProduct != null
                ? AdminProductDetailWeb(
                    product: _detailProduct!,
                    onBack: _closeProductDetail,
                    onEdit: AdminAuthCubit.get(context).isSuperAdmin ? (p) => _closeProductDetail() : null,
                  )
                : _pages[_selected] is AdminOrdersWeb
                        ? AdminOrdersWeb(onOpenDetail: _openOrderDetail)
                        : _pages[_selected] is AdminUsersWeb
                            ? AdminUsersWeb(onOpen: _openUserDetail)
                            : _pages[_selected] is AdminDriversWeb
                                ? AdminDriversWeb(onOpen: _openDriverDetail)
                                : _pages[_selected] is AdminProductsWeb
                                    ? AdminProductsWeb(onOpen: _openProductDetail)
                                    : _pages[_selected];
    return Scaffold(
      backgroundColor: AdminThemeMode.bg(isDark),
      appBar: _buildAppBar(_detailOrderId != null ? titles[3] : titles[_selected], isDark),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(key: ValueKey(_detailOrderId != null ? 'detail' : _selected), child: child),
      ),
      bottomNavigationBar: _detailOrderId != null
          ? null
          : BottomNavigationBar(
              currentIndex: _selected,
              onTap: _select,
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
  PreferredSizeWidget _buildAppBar(String title, bool isDark) {
    return AppBar(
      backgroundColor: AdminThemeMode.surface(isDark),
      foregroundColor: AdminThemeMode.textPrimary(isDark),
      elevation: 0.5,
      title: Text(title, style: appStyle(18, FontWeight.w600, AdminThemeMode.textPrimary(isDark))),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: AdminThemeMode.isDark,
          builder: (context, dark, _) {
            return IconButton(
              icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              tooltip: dark ? 'Light mode' : 'Dark mode',
              onPressed: () => AdminThemeMode.isDark.value = !AdminThemeMode.isDark.value,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
          onPressed: () async {
            final confirmed = await AdminConfirmDialog.show(
              context,
              title: context.t.tr('sign_out_title'),
              message: context.t.tr('sign_out_confirm'),
            );
            if (confirmed) {
              context.read<AdminAuthCubit>().signOut();
              Navigator.pushReplacementNamed(context, AdminLoginWeb.routName);
            }
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
