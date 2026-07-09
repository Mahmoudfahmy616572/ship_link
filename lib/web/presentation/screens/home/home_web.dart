import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';
import 'package:ship_link/web/presentation/screens/favourite/favourite_web.dart';
import 'package:ship_link/web/presentation/screens/notifications/notifications_web.dart';
import 'package:ship_link/web/presentation/shared/shimmer.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/data/models/allProducts/all_products.dart';
import 'package:ship_link/web/domain/repositories/home_repository.dart';
import 'package:ship_link/web/domain/repositories/cart_repository.dart';
import 'package:ship_link/web/data/services_locators.dart';
import 'package:ship_link/web/presentation/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/web/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/search/search_cubit.dart';
import 'package:ship_link/web/presentation/cubits/homeFilter/home_filter_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});
  static String routName = '/home';

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  final _searchCtrl = TextEditingController();
  Timer? _bannerTimer;
  int _currentBanner = 0;
  bool _showDrawer = false;
  List<Product> _allProducts = [];
  bool _loaded = false;

  final _banners = [
    {'title': '30% OFF', 'subtitle': 'Summer Sale!', 'color': const Color(0xFFF97316), 'icon': Icons.wb_sunny},
    {'title': 'Free Shipping', 'subtitle': 'On orders over 500 EGP', 'color': const Color(0xFF3B82F6), 'icon': Icons.local_shipping},
    {'title': 'New Arrivals', 'subtitle': 'Check out latest products', 'color': const Color(0xFF10B981), 'icon': Icons.new_releases},
  ];

  List<Product> get _filtered {
    final searchState = context.read<SearchCubit>().state;
    final filterState = context.read<HomeFilterCubit>().state;
    final category = filterState.selectedCategories.isEmpty ? null : filterState.selectedCategories.first;
    if (searchState is SearchLoaded) return searchState.results;
    var results = List<Product>.from(_allProducts);
    if (category != null) {
      results = results.where((p) => p.category == category).toList();
    }
    switch (filterState.sortBy) {
      case 'price_low': results.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0)); break;
      case 'price_high': results.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0)); break;
      case 'name': results.sort((a, b) => (a.name ?? '').compareTo(b.name ?? '')); break;
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    context.read<GetAllProuductsCubit>().getAllproducts();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _currentBanner = (_currentBanner + 1) % _banners.length);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  Set<String> _extractCategories() {
    return _allProducts
        .where((p) => p.category != null && p.category!.isNotEmpty)
        .map((p) => p.category!)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    final isWide = MediaQuery.of(context).size.width > 900;
    final productsState = context.watch<GetAllProuductsCubit>().state;

    if (productsState is GetAllProuductsSuccess && !_loaded) {
      final all = productsState.products.products?.products ?? [];
      _allProducts = all;
      _loaded = true;
    }

    final loading = productsState is GetAllProuductsLoading || productsState is GetAllProuductsInitial;

    if (loading && !_loaded) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHero(context, false),
            SizedBox(height: 16),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: ShimmerBox(height: 120, radius: 16)),
            SizedBox(height: 16),
            _buildSearch(context),
            ShimmerGrid(count: 6),
          ],
        ),
      );
    }

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (_) => true,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHero(context, isLoggedIn)),
              SliverToBoxAdapter(child: _buildBannerCarousel(context)),
              SliverToBoxAdapter(child: _buildCategoryChips()),
              SliverToBoxAdapter(child: _buildSearch(context)),
              SliverToBoxAdapter(child: _buildSortBar()),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(context.t.tr('products'),
                          style: appStyle(22, FontWeight.w700, const Color(0xFF111827))),
                      const Spacer(),
                      Text('${_filtered.length} ${context.t.tr('items').toLowerCase()}',
                          style: appStyle(13, FontWeight.w500, const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ),
              if (_filtered.isEmpty)
                SliverFillRemaining(child: _buildEmpty())
              else
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 4 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ProductCard(product: _filtered[index], isLoggedIn: isLoggedIn),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_showDrawer) _buildDrawerOverlay(context, isLoggedIn, user),
      ],
    );
  }

  Widget _buildDrawerOverlay(BuildContext context, bool isLoggedIn, User? user) {
    return GestureDetector(
      onTap: () => setState(() => _showDrawer = false),
      child: Row(
        children: [
          Container(
            width: 280,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFF97316), const Color(0xFFFF8A3D)])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      SizedBox(height: 12),
                      Text(isLoggedIn ? (user!.userMetadata?['full_name'] ?? '') : 'Guest',
                          style: appStyle(18, FontWeight.w600, Colors.white)),
                      Text(isLoggedIn ? user!.email ?? '' : 'Sign in to your account',
                          style: appStyle(13, FontWeight.w400, Colors.white70)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _drawerItem(context, Icons.home_rounded, context.t.tr('home'), () => setState(() => _showDrawer = false)),
                      _drawerItem(context, Icons.category_rounded, context.t.tr('categories'), () {
                        context.read<HomeFilterCubit>().clearFilter();
                        setState(() => _showDrawer = false);
                      }),
                      _drawerItem(context, Icons.favorite_outline, context.t.tr('my_favourites'), () {
                        _showDrawer = false;
                        Navigator.pushNamed(context, FavouriteWeb.routName);
                      }),
                      _drawerItem(context, Icons.notifications_outlined, context.t.tr('notifications'), () {
                        _showDrawer = false;
                        Navigator.pushNamed(context, NotificationsWeb.routName);
                      }),
                      _drawerItem(context, Icons.settings_outlined, context.t.tr('settings'), () {
                        _showDrawer = false;
                        Navigator.pushNamed(context, '/settings');
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ShipLink v1.0', style: appStyle(12, FontWeight.w400, const Color(0xFF9CA3AF))),
                ),
              ],
            ),
          ),
          Expanded(child: Container(color: Colors.black26)),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return HoverScale(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6B7280)),
        title: Text(label, style: appStyle(15, FontWeight.w500, const Color(0xFF111827))),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: const Color(0xFFD1D5DB)),
          SizedBox(height: 16),
          Text(context.t.tr('no_products'), style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isLoggedIn) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          HoverScale(
            onTap: () => setState(() => _showDrawer = !_showDrawer),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.menu_rounded, color: Colors.white, size: 24),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t.tr('welcome_to_shiplink'),
                    style: appStyle(24, FontWeight.w700, Colors.white)),
                SizedBox(height: 4),
                Text(context.t.tr('shop_description'),
                    style: appStyle(14, FontWeight.w400, Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(BuildContext context) {
    final banner = _banners[_currentBanner];
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HoverScale(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [banner['color'] as Color, (banner['color'] as Color).withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(banner['icon'] as IconData, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(banner['title'] as String,
                        style: appStyle(20, FontWeight.w700, Colors.white)),
                    SizedBox(height: 4),
                    Text(banner['subtitle'] as String,
                        style: appStyle(14, FontWeight.w400, Colors.white70)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_banners.length, (i) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  width: i == _currentBanner ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _currentBanner ? Colors.white : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final cats = _extractCategories().toList()..sort();
    final filterState = context.watch<HomeFilterCubit>().state;
    if (cats.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cats.length + 1,
          separatorBuilder: (_, __) => SizedBox(width: 8),
          itemBuilder: (_, i) {
            final isAll = i == 0;
            final selectedCat = filterState.selectedCategories.isEmpty ? null : filterState.selectedCategories.first;
            final isSelected = isAll ? selectedCat == null : selectedCat == cats[i - 1];
            final label = isAll ? context.t.tr('all') : cats[i - 1];
            return HoverScale(
              onTap: () => isAll
                  ? context.read<HomeFilterCubit>().clearFilter()
                  : context.read<HomeFilterCubit>().toggleCategory(cats[i - 1]),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: Text(label,
                      style: appStyle(13, FontWeight.w500,
                          isSelected ? Colors.white : const Color(0xFF6B7280))),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: context.t.tr('search_products'),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
          suffixIcon: context.watch<SearchCubit>().state is SearchInitial
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () { _searchCtrl.clear(); context.read<SearchCubit>().search('', _allProducts); },
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (v) => context.read<SearchCubit>().search(v, _allProducts),
      ),
    );
  }

  Widget _buildSortBar() {
    final sortBy = context.watch<HomeFilterCubit>().state.sortBy;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Icon(Icons.sort, size: 18, color: const Color(0xFF6B7280)),
          SizedBox(width: 6),
          Text(context.t.tr('sort_by'), style: appStyle(13, FontWeight.w500, const Color(0xFF6B7280))),
          SizedBox(width: 8),
          DropdownButton<String>(
            value: sortBy.isEmpty ? 'newest' : sortBy,
            underline: const SizedBox(),
            isDense: true,
            style: appStyle(13, FontWeight.w500, const Color(0xFF111827)),
            items: [
              DropdownMenuItem(value: 'newest', child: Text(context.t.tr('newest'))),
              DropdownMenuItem(value: 'price_low', child: Text(context.t.tr('price_low_to_high'))),
              DropdownMenuItem(value: 'price_high', child: Text(context.t.tr('price_high_to_low'))),
              DropdownMenuItem(value: 'name', child: Text(context.t.tr('name'))),
            ],
            onChanged: (v) => context.read<HomeFilterCubit>().setSortBy(v ?? ''),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isLoggedIn;

  const _ProductCard({required this.product, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final id = product.id ?? 0;
    final name = product.name ?? '';
    final price = (product.price ?? 0).toDouble();
    final image = product.image ?? '';
    final currency = context.t.tr('egp');

    return HoverScale(
      child: GestureDetector(
        onTap: () => _showDetail(context),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: 'product_$id',
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, c, p) => p == null
                          ? c
                          : Container(color: const Color(0xFFF3F4F6), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.image_outlined, size: 40, color: Color(0xFFD1D5DB)),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: appStyle(13, FontWeight.w500, const Color(0xFF111827)),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Text('$currency ${price.toStringAsFixed(0)}',
                        style: appStyle(16, FontWeight.w700, AppColors.cta)),
                    SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: _TapScale(
                        onTap: () => _addToCart(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(context.t.tr('add_to_cart'),
                                style: appStyle(11, FontWeight.w600, Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) async {
    if (!isLoggedIn) {
      Navigator.pushNamed(context, WelcomeWeb.routName);
      return;
    }
    context.read<AddToCartCubit>().addToCart(id: product.id, quantity: 1);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name ?? ''} ${context.t.tr('added_to_cart')}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetail(product: product, isLoggedIn: isLoggedIn),
    );
  }
}

class _ProductDetail extends StatefulWidget {
  final Product product;
  final bool isLoggedIn;
  const _ProductDetail({required this.product, required this.isLoggedIn});

  @override
  State<_ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<_ProductDetail> with SingleTickerProviderStateMixin {
  int _qty = 1;
  bool _adding = false;
  bool _added = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.product.id ?? 0;
    final name = widget.product.name ?? '';
    final price = (widget.product.price ?? 0).toDouble();
    final currency = context.t.tr('egp');
    final description = widget.product.description ?? '';
    final image = widget.product.image ?? '';
    final category = widget.product.category ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              child: Hero(
                tag: 'product_$id',
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, c, p) => p == null
                      ? c
                      : Container(height: 280, color: const Color(0xFFF3F4F6), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  errorBuilder: (_, __, ___) => Container(
                    height: 280, color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.image_outlined, size: 64, color: Color(0xFFD1D5DB)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(category,
                          style: appStyle(12, FontWeight.w500, AppColors.primary)),
                    ),
                  SizedBox(height: 12),
                  Text(name, style: appStyle(24, FontWeight.w700, const Color(0xFF111827))),
                  SizedBox(height: 8),
                  Text('$currency ${price.toStringAsFixed(0)}',
                      style: appStyle(32, FontWeight.w700, AppColors.cta)),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 16),
                    const Divider(),
                    SizedBox(height: 16),
                    Text(context.t.tr('description'),
                        style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
                    SizedBox(height: 8),
                    Text(description,
                        style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                  ],
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Text(context.t.tr('quantity'),
                          style: appStyle(15, FontWeight.w500, const Color(0xFF111827))),
                      SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _qtyBtn(Icons.remove_rounded, _qty > 1 ? () => setState(() => _qty--) : null),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$_qty',
                                  style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
                            ),
                            _qtyBtn(Icons.add_rounded, () => setState(() => _qty++)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _adding ? null : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _adding
                          ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : _added
                              ? ScaleTransition(
                                  scale: _scaleAnim,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, size: 20, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(context.t.tr('added_to_cart'),
                                          style: appStyle(16, FontWeight.w600, Colors.white)),
                                    ],
                                  ),
                                )
                              : Text('${context.t.tr('add_to_cart')} · $currency ${(price * _qty).toStringAsFixed(0)}',
                                  style: appStyle(16, FontWeight.w600, Colors.white)),
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

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.transparent,
        child: Icon(icon, size: 20, color: onTap != null ? const Color(0xFF111827) : const Color(0xFFD1D5DB)),
      ),
    );
  }

  void _addToCart() async {
    if (!widget.isLoggedIn) {
      Navigator.pushNamed(context, WelcomeWeb.routName);
      return;
    }
    setState(() => _adding = true);
    context.read<AddToCartCubit>().addToCart(id: widget.product.id, quantity: _qty);
    if (mounted) {
      setState(() { _adding = false; _added = true; });
      _animCtrl.forward();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _added = false);
      });
    }
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _TapScale({required this.child, this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _anim = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(animation: _anim, builder: (_, c) => Transform.scale(scale: _anim.value, child: c), child: widget.child),
    );
  }
}
