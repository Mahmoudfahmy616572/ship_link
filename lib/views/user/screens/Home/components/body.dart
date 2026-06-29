import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/data/models/allProducts/all_products.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/notification_bell.dart';
import 'package:ship_link/views/user/screens/Home/components/carousel_banner.dart';
import 'package:ship_link/views/user/screens/Home/components/favourite_brands.dart';
import 'package:ship_link/views/user/screens/Home/components/main_row_category.dart';
import 'package:ship_link/views/user/screens/Home/components/top_seller_screen.dart';
import 'package:ship_link/views/user/screens/Home/components/grid_cart.dart';
import 'package:ship_link/views/user/screens/chat/chat_list_screen.dart';

import '../../../../shared/app_style.dart';
import '../../../../shared/shimmer/shimmer_loading.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Set<String> _selectedCategories = {};
  int _visibleCount = 10;
  String _sortBy = '';
  final ScrollController _scrollController = ScrollController();

  List<Product> get _allProducts {
    final state = context.read<GetAllProuductsCubit>().state;
    if (state is GetAllProuductsSuccess) {
      return state.products.products?.products ?? [];
    }
    return [];
  }

  static const _sortOptions = [
    '', 'price_asc', 'price_desc', 'newest', 'name_az', 'name_za',
  ];

  List<Product> _sorted(List<Product> products) {
    if (_sortBy.isEmpty) return products;
    final sorted = List<Product>.from(products);
    switch (_sortBy) {
      case 'price_asc':
        sorted.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_desc':
        sorted.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'newest':
        sorted.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        break;
      case 'name_az':
        sorted.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case 'name_za':
        sorted.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
        break;
    }
    return sorted;
  }

  List<Product> get _displayProducts {
    final all = _allProducts;
    if (_selectedCategories.isEmpty) return _sorted(all).take(_visibleCount).toList();
    final filtered = all.where((p) => p.category != null && _selectedCategories.contains(p.category)).toList();
    return _sorted(filtered).take(_visibleCount).toList();
  }

  List<Product> get _topSellers {
    return _allProducts.where((p) => p.id != null && p.id! <= 6).toList();
  }

  List<Product> get _offerProducts {
    final all = _allProducts;
    if (all.length < 6) return all;
    return [all[3], all[4], all[5]];
  }

  int get _totalCount {
    if (_selectedCategories.isNotEmpty) {
      return _allProducts.where((p) => p.category != null && _selectedCategories.contains(p.category)).length;
    }
    return _allProducts.length;
  }

  bool get _hasMore => _visibleCount < _totalCount;
  bool get _isFiltering => _selectedCategories.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      if (_hasMore) setState(() => _visibleCount += 10);
    }
  }

  void _onBrandTap(Set<String> categories) {
    setState(() {
      _selectedCategories = (_selectedCategories == categories) ? {} : categories;
      _visibleCount = 10;
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedCategories = {};
      _visibleCount = 10;
    });
  }

  Product? _productAt(int index) {
    if (index < _displayProducts.length) return _displayProducts[index];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAllProuductsCubit, GetAllProuductsState>(
      buildWhen: (prev, cur) => prev.runtimeType != cur.runtimeType,
      builder: (context, state) {
        if (state is GetAllProuductsFailure) {
          return _buildError(state.errMessage);
        }
        if (state is GetAllProuductsLoading && _allProducts.isEmpty) {
          return ShimmerLoading.grid();
        }
        return _buildHomeContent();
      },
    );
  }

  Widget _buildError(String errMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64.sp, color: AppColors.textHint),
            SizedBox(height: 16.h),
            Text(context.t.tr('could_not_load_products'),
                style: appStyle(18, FontWeight.w600, AppColors.textPrimary)),
            SizedBox(height: 8.h),
            Text(errMessage,
                textAlign: TextAlign.center,
                style: appStyle(14, FontWeight.normal, AppColors.textSecondary)),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => context.read<GetAllProuductsCubit>().getAllproducts(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: Text(context.t.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.11),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const NotificationBell(iconColor: AppColors.headerIcons),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.headerIcons),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen())),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      CarouselBanner(products: _offerProducts),
                      SizedBox(height: 24.h),
                      _SectionHeader(title: context.t.tr('top_categories')),
                      SizedBox(height: 14.h),
                      FavouriteBrands(selectedCategories: _selectedCategories, onBrandTap: _onBrandTap),
                      SizedBox(height: 28.h),
                      _SectionHeader(title: context.t.tr('top_seller_products'), trailing: context.t.tr('view_all'), onTrailingTap: () => Navigator.pushNamed(context, TopSellerScreen.routName)),
                      SizedBox(height: 14.h),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: BuildCategoryMainRow(topSellers: _topSellers),
                      ),
                      SizedBox(height: 28.h),
                      _SectionHeader(
                        title: _isFiltering ? context.t.tr('filtered_products') : context.t.tr('all_products'),
                        trailing: _isFiltering ? context.t.tr('clear_filter') : null,
                        onTrailingTap: _isFiltering ? _clearFilter : null,
                      ),
                      SizedBox(height: 14.h),
                      _SortBar(
                        selected: _sortBy,
                        onChanged: (v) => setState(() => _sortBy = v),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, rowIndex) {
                        final leftIdx = rowIndex * 2;
                        final rightIdx = rowIndex * 2 + 1;
                        if (leftIdx >= _displayProducts.length) {
                          return const SizedBox.shrink();
                        }
                        final leftP = _productAt(leftIdx);
                        final rightP = rightIdx < _displayProducts.length
                            ? _productAt(rightIdx)
                            : null;
                        if (leftP == null) return const SizedBox.shrink();
                        final leftOrig = _allProducts.indexOf(leftP);
                        final rightOrig = rightP != null
                            ? _allProducts.indexOf(rightP)
                            : -1;
                        final leftTall = rowIndex % 2 == 0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: RepaintBoundary(
                                  child: DesignGridCard(
                                    key: ValueKey('prod_${leftP.id}'),
                                    product: leftP,
                                    index: leftOrig >= 0 ? leftOrig : leftIdx,
                                    isTall: leftTall,
                                  ),
                                ),
                              ),
                              if (rightP != null) SizedBox(width: 10.w),
                              if (rightP != null)
                                Expanded(
                                  child: RepaintBoundary(
                                    child: DesignGridCard(
                                      key: ValueKey('prod_${rightP.id}'),
                                      product: rightP,
                                      index: rightOrig >= 0
                                          ? rightOrig
                                          : rightIdx,
                                      isTall: !leftTall,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      childCount: (_displayProducts.length + 1) ~/ 2,
                    ),
                  ),
                ),
                if (_hasMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Center(child: SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2))),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _SortBar({required this.selected, required this.onChanged});

  static const _labels = {
    '': 'Default',
    'price_asc': 'Price ↑',
    'price_desc': 'Price ↓',
    'newest': 'Newest',
    'name_az': 'A-Z',
    'name_za': 'Z-A',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final entry = _labels.entries.elementAt(index);
          final isSelected = selected == entry.key;
          return GestureDetector(
            onTap: () => onChanged(entry.key),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cta : AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: isSelected ? AppColors.cta : AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.value,
                style: appStyle(12, FontWeight.w500, isSelected ? Colors.white : AppColors.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const _SectionHeader({required this.title, this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Container(width: 4.w, height: 20.h, decoration: BoxDecoration(color: AppColors.cta, borderRadius: BorderRadius.circular(2.r))),
          SizedBox(width: 10.w),
          Text(title, style: appStyle(20, FontWeight.w700, Colors.black)),
          const Spacer(),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Row(
                children: [
                  Text(trailing!, style: appStyle(13, FontWeight.w500, AppColors.cta)),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_ios, size: 12.sp, color: AppColors.cta),
                ],
              ),
            ),
        ],
      ),
    );
  }
}