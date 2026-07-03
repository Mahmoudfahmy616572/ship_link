import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/services/auth_service_web.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/web/screens/home/home_web.dart';
import 'package:ship_link/views/web/screens/cart/cart_web.dart';
import 'package:ship_link/views/web/screens/orders/orders_web.dart';
import 'package:ship_link/views/web/screens/profile/profile_web.dart';

class WebScaffold extends StatefulWidget {
  static String routName = '/';
  final Widget? initialPage;
  const WebScaffold({super.key, this.initialPage});

  @override
  State<WebScaffold> createState() => _WebScaffoldState();
}

class _WebScaffoldState extends State<WebScaffold> {
  int _selectedIndex = 0;
  late List<_NavItem> _navItems;
  final _titles = <String>['home_bottom', 'cart', 'orders', 'profile'];

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0: return const HomeWeb();
      case 1: return const CartWeb();
      case 2: return const OrdersWeb();
      case 3: return const ProfileWeb();
      default: return const HomeWeb();
    }
  }

  @override
  void initState() {
    super.initState();
    _navItems = [];
  }

  void _initNav() {
    if (_navItems.isNotEmpty) return;
    final t = context.t;
    _navItems = [
      _NavItem(Icons.home_rounded, t.tr('home'), 0),
      _NavItem(Icons.shopping_cart_rounded, t.tr('cart'), 1),
      _NavItem(Icons.receipt_long_rounded, t.tr('orders'), 2),
      _NavItem(Icons.person_rounded, t.tr('profile'), 3),
    ];
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onBack() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _initNav();
    final isWide = MediaQuery.of(context).size.width > 900;
    final auth = context.watch<AuthServiceWeb>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: isWide ? _buildWide(context, auth) : _buildNarrow(context, auth),
    );
  }

  Widget _buildWide(BuildContext context, AuthServiceWeb auth) {
    return Row(
      children: [
        _SideNav(
          selectedIndex: _selectedIndex,
          items: _navItems,
          onTap: _onNavTap,
          isLoggedIn: auth.status == WebAuthStatus.authenticated,
          userName: auth.user?.userMetadata?['full_name'] ?? '',
        ),
        Expanded(
          child: Scaffold(
            appBar: _buildAppBar(context),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: _buildPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrow(BuildContext context, AuthServiceWeb auth) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: _buildPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        items: _navItems
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(e.icon),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF111827),
      elevation: 0.5,
      title: Text(_titles[_selectedIndex],
          style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => Navigator.pushNamed(context, CartWeb.routName),
        ),
      ],
    );
  }
}

class _SideNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final bool isLoggedIn;
  final String userName;

  const _SideNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.isLoggedIn,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('ShipLink',
                    style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isSelected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Material(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onTap(i),
                      child: ListTile(
                        leading: Icon(item.icon,
                            color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
                            size: 22),
                        title: Text(item.label,
                            style: appStyle(
                              15,
                              FontWeight.w500,
                              isSelected ? AppColors.primary : const Color(0xFF374151),
                            )),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (isLoggedIn) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(userName,
                        style: appStyle(14, FontWeight.w500, const Color(0xFF111827)),
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 20, color: Color(0xFF6B7280)),
                    onPressed: () {
                      context.read<AuthServiceWeb>().signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  _NavItem(this.icon, this.label, this.index);
}
