import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/user/presentation/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/user/presentation/cubits/search/search_cubit.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';
import 'package:ship_link/user/domain/repositories/home_repository.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/user/presentation/screens/product/product_screen.dart';

import 'package:ship_link/user/presentation/screens/searchScreen/components/text_feild.dart';

class Search extends StatefulWidget {
  const Search({super.key});
  static String routName = '/Search';

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late final SearchCubit _cubit;
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = SearchCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetAllProuductsCubit(
        getIt.get<HomeRepository>(),
      )..getAllproducts(),
      child: BlocBuilder<GetAllProuductsCubit, GetAllProuductsState>(
        builder: (context, state) {
          final List<Product> products = state is GetAllProuductsSuccess
              ? state.products.products?.products ?? []
              : [];
          return _SearchContent(
            cubit: _cubit,
            products: products,
            minPriceCtrl: _minPriceCtrl,
            maxPriceCtrl: _maxPriceCtrl,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  final SearchCubit cubit;
  final List<Product> products;
  final TextEditingController minPriceCtrl;
  final TextEditingController maxPriceCtrl;
  final ScrollController scrollController;

  const _SearchContent({
    required this.cubit,
    required this.products,
    required this.minPriceCtrl,
    required this.maxPriceCtrl,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final categories = cubit.extractCategories(products).toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          context.t.tr('app_bar_search'),
          style: appStyle(18, FontWeight.w600, AppColors.textPrimary),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: BlocBuilder<SearchCubit, SearchState>(
          bloc: cubit,
          builder: (context, searchState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildTextField(
                  onChanged: (query) => cubit.search(query, products,
                      category: cubit.selectedCategory,
                      sortBy: cubit.sortBy),
                ),
                SizedBox(height: 12.h),
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 40.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final isSelected = isAll
                            ? cubit.selectedCategory == null
                            : categories[index - 1] == cubit.selectedCategory;
                        final label = isAll
                            ? context.t.tr('all')
                            : categories[index - 1];
                        return FilterChip(
                          label: Text(
                            label,
                            style: appStyle(
                              13,
                              FontWeight.w500,
                              isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) =>
                              cubit.filterByCategory(isAll ? '' : categories[index - 1], products),
                          selectedColor: AppColors.cta,
                          checkmarkColor: Colors.white,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.cta : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: context.t.tr('min_price'),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        onChanged: (_) {
                          final minP = double.tryParse(minPriceCtrl.text.trim());
                          final maxP = double.tryParse(maxPriceCtrl.text.trim());
                          cubit.search(cubit.searchQuery, products,
                              category: cubit.selectedCategory,
                              minPrice: minP,
                              maxPrice: maxP,
                              sortBy: cubit.sortBy);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text('-', style: appStyle(16, FontWeight.w600, AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: maxPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: context.t.tr('max_price'),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        onChanged: (_) {
                          final minP = double.tryParse(minPriceCtrl.text.trim());
                          final maxP = double.tryParse(maxPriceCtrl.text.trim());
                          cubit.search(cubit.searchQuery, products,
                              category: cubit.selectedCategory,
                              minPrice: minP,
                              maxPrice: maxP,
                              sortBy: cubit.sortBy);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _SearchSortBar(
                  selected: cubit.sortBy,
                  onChanged: (key) {
                    final minP = double.tryParse(minPriceCtrl.text.trim());
                    final maxP = double.tryParse(maxPriceCtrl.text.trim());
                    cubit.search(cubit.searchQuery, products,
                        category: cubit.selectedCategory,
                        minPrice: minP,
                        maxPrice: maxP,
                        sortBy: key);
                  },
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: _buildSearchResults(context, searchState),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchState searchState) {
    if (searchState is SearchInitial) {
      return Center(
        child: Text(
          context.t.tr('search_for_products'),
          style: appStyle(16, FontWeight.normal, AppColors.textHint),
        ),
      );
    }
    if (searchState is SearchLoading) {
      return ShimmerLoading.searchList();
    }
    if (searchState is SearchLoaded) {
      final results = searchState.results;
      if (results.isEmpty) {
        return Center(
          child: Text(
            context.t.tr('no_products_found'),
            style: appStyle(16, FontWeight.normal, AppColors.textHint),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => context.read<GetAllProuductsCubit>().getAllproducts(),
        child: ListView.builder(
          controller: scrollController,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            return _SearchResultItem(product: product);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _SearchSortBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _SearchSortBar({required this.selected, required this.onChanged});

  static const _keys = ['', 'price_asc', 'price_desc', 'newest', 'name_az', 'name_za'];

  String _label(BuildContext context, String key) {
    switch (key) {
      case '': return context.t.tr('sort_default');
      case 'price_asc': return context.t.tr('sort_price_asc');
      case 'price_desc': return context.t.tr('sort_price_desc');
      case 'newest': return context.t.tr('sort_newest');
      case 'name_az': return context.t.tr('sort_name_az');
      case 'name_za': return context.t.tr('sort_name_za');
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _keys.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final key = _keys[index];
          final isSelected = selected == key;
          return GestureDetector(
            onTap: () => onChanged(key),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cta : AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: isSelected ? AppColors.cta : AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                _label(context, key),
                style: appStyle(12, FontWeight.w500, isSelected ? Colors.white : AppColors.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Product product;
  const _SearchResultItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductScreen(product: product)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.surface,
                image: product.image != null
                    ? DecorationImage(
                        image: NetworkImage(product.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.image == null
                  ? const Icon(Icons.image, color: AppColors.textHint)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "Unknown",
                    style: appStyle(16, FontWeight.w500, AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.category ?? "",
                    style: appStyle(13, FontWeight.normal, AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              "\$${product.price?.toStringAsFixed(2) ?? "0.00"}",
              style: appStyle(16, FontWeight.w600, AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
