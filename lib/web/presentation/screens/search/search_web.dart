import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/web/presentation/cubits/search/search_cubit.dart';
import 'package:ship_link/web/data/models/allProducts/all_products.dart';
import 'package:ship_link/web/presentation/screens/product_details/product_details_web.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/core/utils/sizer.dart';

class SearchWeb extends StatefulWidget {
  const SearchWeb({super.key});
  static String routName = '/search';

  @override
  State<SearchWeb> createState() => _SearchWebState();
}

class _SearchWebState extends State<SearchWeb> {
  late final SearchCubit _cubit;
  final _searchCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _cubit = SearchCubit();
    _loadProducts();
  }

  void _loadProducts() {
    final state = context.read<GetAllProuductsCubit>().state;
    if (state is GetAllProuductsSuccess) {
      _allProducts = state.products.products?.products ?? [];
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _searchCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allProductsState = context.watch<GetAllProuductsCubit>().state;
    if (allProductsState is GetAllProuductsSuccess) {
      _allProducts = allProductsState.products.products?.products ?? [];
    }
    final products = _allProducts;
    final categories = _cubit.extractCategories(products).toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(context.t.tr('app_bar_search'), style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        bloc: _cubit,
        builder: (context, searchState) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchField(),
                SizedBox(height: 12),
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final isAll = index == 0;
                        final isSelected = isAll ? _cubit.selectedCategory == null : categories[index - 1] == _cubit.selectedCategory;
                        return FilterChip(
                          label: Text(
                            isAll ? context.t.tr('all') : categories[index - 1],
                            style: appStyle(13, FontWeight.w500, isSelected ? Colors.white : const Color(0xFF6B7280)),
                          ),
                          selected: isSelected,
                          onSelected: (_) => _cubit.filterByCategory(isAll ? '' : categories[index - 1], products),
                          selectedColor: AppColors.cta,
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppColors.cta : const Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: context.t.tr('min_price'),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (_) => _search(),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-', style: appStyle(16, FontWeight.w600, const Color(0xFF6B7280)))),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: context.t.tr('max_price'),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (_) => _search(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _sortBar(),
                SizedBox(height: 12),
                Expanded(child: _results(searchState, products)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: context.t.tr('search_hint'),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (_) => _search(),
      ),
    );
  }

  void _search() {
    final minP = double.tryParse(_minPriceCtrl.text.trim());
    final maxP = double.tryParse(_maxPriceCtrl.text.trim());
    _cubit.search(_searchCtrl.text.trim(), _allProducts,
        category: _cubit.selectedCategory, minPrice: minP, maxPrice: maxP, sortBy: _cubit.sortBy);
  }

  Widget _sortBar() {
    final keys = ['', 'price_asc', 'price_desc', 'newest', 'name_az', 'name_za'];
    String label(String key) {
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
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: keys.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (_, index) {
          final key = keys[index];
          final isSelected = _cubit.sortBy == key;
          return GestureDetector(
            onTap: () {
              _cubit.search(_searchCtrl.text.trim(), _allProducts,
                  category: _cubit.selectedCategory,
                  minPrice: double.tryParse(_minPriceCtrl.text.trim()),
                  maxPrice: double.tryParse(_maxPriceCtrl.text.trim()),
                  sortBy: key);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cta : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.cta : const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.center,
              child: Text(label(key), style: appStyle(12, FontWeight.w500, isSelected ? Colors.white : const Color(0xFF6B7280))),
            ),
          );
        },
      ),
    );
  }

  Widget _results(SearchState searchState, List<Product> products) {
    if (searchState is SearchInitial) {
      return Center(child: Text(context.t.tr('search_for_products'), style: appStyle(16, FontWeight.w400, const Color(0xFFD1D5DB))));
    }
    if (searchState is SearchLoading) {
      return ShimmerLoading.searchList();
    }
    if (searchState is SearchLoaded) {
      final results = searchState.results;
      if (results.isEmpty) {
        return Center(child: Text(context.t.tr('no_products_found'), style: appStyle(16, FontWeight.w400, const Color(0xFFD1D5DB))));
      }
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (_, index) {
          final product = results[index];
          return _resultItem(product);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _resultItem(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsWeb(product: product)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF3F4F6),
                image: product.image != null
                    ? DecorationImage(image: NetworkImage(product.image!), fit: BoxFit.cover)
                    : null,
              ),
              child: product.image == null
                  ? const Icon(Icons.image, color: Color(0xFFD1D5DB))
                  : null,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name ?? '', style: appStyle(16, FontWeight.w500, const Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(product.category ?? '', style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                ],
              ),
            ),
            Text('${context.t.tr('egp')} ${product.price?.toStringAsFixed(0) ?? '0'}',
                style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
          ],
        ),
      ),
    );
  }
}
