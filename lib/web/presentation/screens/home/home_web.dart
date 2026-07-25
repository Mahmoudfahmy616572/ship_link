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
import 'package:ship_link/web/presentation/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/web/presentation/screens/product_details/product_details_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});
  static String routName = '/home';

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  final _searchCtrl = TextEditingController();
  final PageController _bannerPageCtrl = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;
  bool _showDrawer = false;
  List<Product> _allProducts = [];
  bool _loaded = false;

  List<String> _categories = [];
  String? _selectedCategory;

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
    context.read<GetTopSellerCubit>().getTopSellerProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bannerPageCtrl.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  Set<String> _extractCategories() {
    return _allProducts
        .where((p) => p.category != null && p.category!.isNotEmpty)
        .map((p) => p.category!)
        .toSet();
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
        return Icons.restaurant;
      case 'perfume':
      case 'fragrances':
      case 'perfumes':
        return Icons.spa;
      case 'furniture':
      case 'home-decoration':
      case 'home':
        return Icons.chair;
      case 'electronics':
      case 'laptops':
      case 'smartphones':
      case 'tablets':
        return Icons.devices;
      case 'beauty':
      case 'skincare':
      case 'cosmetics':
        return Icons.face;
      case 'clothing':
      case 'mens-shirts':
      case 'mens-shoes':
      case 'womens-dresses':
      case 'womens-shoes':
      case 'tops':
      case 'fashion':
        return Icons.checkroom;
      case 'automotive':
      case 'cars':
        return Icons.directions_car;
      case 'books':
      case 'education':
        return Icons.menu_book;
      case 'sports':
        return Icons.sports_soccer;
      case 'toys':
      case 'games':
        return Icons.toys;
      case 'jewelry':
      case 'jewellery':
      case 'accessories':
        return Icons.diamond;
      case 'health':
      case 'medical':
        return Icons.medical_services;
      case 'bags':
      case 'womens-bags':
        return Icons.shopping_bag;
      case 'pet':
      case 'pets':
      case 'pet-supplies':
        return Icons.pets;
      case 'office':
      case 'office-supplies':
        return Icons.work;
      case 'tools':
      case 'hardware':
        return Icons.build;
      case 'music':
        return Icons.music_note;
      default:
        return Icons.category;
    }
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
      _categories = all
          .where((p) => p.category != null && p.category!.isNotEmpty)
          .map((p) => p.category!)
          .toSet()
          .toList()
        ..sort();
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _allProducts.isNotEmpty) {
          _bannerTimer?.cancel();
          _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
            if (mounted && _allProducts.isNotEmpty) {
              final next = (_currentBanner + 1) % _allProducts.length;
              _bannerPageCtrl.animateToPage(
                next,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      });
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
              SliverToBoxAdapter(child: _buildFavouriteBrands()),
              SliverToBoxAdapter(child: _buildCategoryChips()),
              SliverToBoxAdapter(child: _buildSearch(context)),
              SliverToBoxAdapter(child: _buildSortBar()),
              SliverToBoxAdapter(child: _buildTopSellersSection()),
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
    if (_allProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    final discounts = [30, 20, 15, 10];
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerPageCtrl,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemCount: _allProducts.length.clamp(0, 8),
            itemBuilder: (context, index) {
              final product = _allProducts[index];
              final discount = discounts[index % discounts.length];
              return _BannerCardWeb(product: product, discount: discount);
            },
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<int>(
          valueListenable: ValueNotifier(_currentBanner),
          builder: (context, currentPage, _) {
            final count = _allProducts.length.clamp(0, 8);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: currentPage == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentPage == i ? AppColors.cta : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFavouriteBrands() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.tr('categories'),
              style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final filterState = context.watch<HomeFilterCubit>().state;
                final selectedCat = filterState.selectedCategories.isEmpty
                    ? null
                    : filterState.selectedCategories.first;
                final isSelected = category == selectedCat;
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      context.read<HomeFilterCubit>().clearFilter();
                    } else {
                      context.read<HomeFilterCubit>().toggleCategory(category);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cta : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.cta : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.cta.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _categoryIcon(category),
                          size: 28,
                          color: isSelected ? Colors.white : AppColors.cta,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

  Widget _buildTopSellersSection() {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    return BlocBuilder<GetTopSellerCubit, GetTopSellerState>(
      builder: (context, state) {
        if (state is GetTopSellerLoading) {
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t.tr('top_seller_products'), style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
                SizedBox(height: 12),
                SizedBox(height: 200, child: ShimmerGrid(count: 3)),
              ],
            ),
          );
        }
        if (state is GetTopSellerSuccess) {
          final sellers = state.getTopSeller.topSellers ?? [];
          if (sellers.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(context.t.tr('top_seller_products'), style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
                    const Spacer(),
                    Icon(Icons.local_fire_department, color: AppColors.cta, size: 20),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: sellers.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final seller = sellers[index];
                      return _TopSellerCard(seller: seller, isLoggedIn: isLoggedIn);
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
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

class _BannerCardWeb extends StatelessWidget {
  final Product product;
  final int discount;
  const _BannerCardWeb({required this.product, required this.discount});

  @override
  Widget build(BuildContext context) {
    final image = product.image ?? '';
    final name = product.name ?? '';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ProductDetailsWeb.routName, arguments: product),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF3F4F6)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.t.tr('special_offer'), style: appStyle(13, FontWeight.w500, AppColors.cta)),
                    SizedBox(height: 4),
                    Text('${context.t.tr('up_to_off').replaceAll('%', '')}$discount%', style: appStyle(26, FontWeight.w800, Colors.white)),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.cta, borderRadius: BorderRadius.circular(20)),
                      child: Text(context.t.tr('shop_now'), style: appStyle(12, FontWeight.w600, Colors.white)),
                    ),
                  ],
                ),
              ),
              Positioned(bottom: 12, right: 12, child: Text(name, style: appStyle(12, FontWeight.w400, Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopSellerCard extends StatelessWidget {
  final dynamic seller;
  final bool isLoggedIn;
  const _TopSellerCard({required this.seller, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final name = seller.name ?? '';
    final price = (seller.price ?? 0).toDouble();
    final image = seller.image ?? '';
    final currency = context.t.tr('egp');

    return GestureDetector(
      onTap: () {
        final product = Product(
          id: seller.id,
          name: seller.name,
          description: seller.description,
          image: seller.image,
          price: seller.price,
          category: seller.category,
          images: seller.images,
        );
        Navigator.pushNamed(context, ProductDetailsWeb.routName, arguments: product);
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.local_fire_department, size: 32, color: Color(0xFFF97316)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: appStyle(12, FontWeight.w500, const Color(0xFF111827)),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text('$currency ${price.toStringAsFixed(0)}',
                      style: appStyle(14, FontWeight.w700, AppColors.cta)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
