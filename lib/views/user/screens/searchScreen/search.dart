import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/cubits/search/search_cubit.dart';
import 'package:ship_link/data/models/allProducts/all_products.dart';
import 'package:ship_link/data/services/homeServeice/home_serveices_impl.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';
import 'package:ship_link/views/user/screens/product/product_screen.dart';

import 'components/text_feild.dart';

class Search extends StatefulWidget {
  const Search({super.key});
  static String routName = '/Search';

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late final SearchCubit _cubit;
  String? _selectedCategory;
  String _sortBy = '';
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

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
    super.dispose();
  }

  void _onSearch(List<Product> products) {
    final minP = double.tryParse(_minPriceCtrl.text.trim());
    final maxP = double.tryParse(_maxPriceCtrl.text.trim());
    _cubit.search(_cubit.searchQuery, products,
        category: _selectedCategory, minPrice: minP, maxPrice: maxP, sortBy: _sortBy);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetAllProuductsCubit(
        getIt.get<HomeServeicesImpl>(),
      )..getAllproducts(),
      child: BlocBuilder<GetAllProuductsCubit, GetAllProuductsState>(
        builder: (context, state) {
          final List<Product> products = state is GetAllProuductsSuccess
              ? state.products.products?.products ?? []
              : [];
          return _SearchContent(
            cubit: _cubit,
            products: products,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (cat) {
              setState(() => _selectedCategory = cat);
              _onSearch(products);
            },
            minPriceCtrl: _minPriceCtrl,
            maxPriceCtrl: _maxPriceCtrl,
            onPriceChanged: () => _onSearch(products),
            sortBy: _sortBy,
            onSortChanged: (v) {
              setState(() => _sortBy = v);
              _onSearch(products);
            },
          );
        },
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  final SearchCubit cubit;
  final List<Product> products;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController minPriceCtrl;
  final TextEditingController maxPriceCtrl;
  final VoidCallback onPriceChanged;
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  const _SearchContent({
    required this.cubit,
    required this.products,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.minPriceCtrl,
    required this.maxPriceCtrl,
    required this.onPriceChanged,
    required this.sortBy,
    required this.onSortChanged,
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
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildTextField(
              onChanged: (query) => cubit.search(query, products, category: selectedCategory),
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
                    final isSelected = isAll ? selectedCategory == null : categories[index - 1] == selectedCategory;
                    final label = isAll ? context.t.tr('all') : categories[index - 1];
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
                      onSelected: (_) => onCategoryChanged(isAll ? null : categories[index - 1]),
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
                    onChanged: (_) => onPriceChanged(),
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
                    onChanged: (_) => onPriceChanged(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _SearchSortBar(selected: sortBy, onChanged: onSortChanged),
            SizedBox(height: 12.h),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                bloc: cubit,
                builder: (context, searchState) {
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
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final product = results[index];
                        return _SearchResultItem(product: product);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSortBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _SearchSortBar({required this.selected, required this.onChanged});

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
