import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
  Timer? _debounce;
  String _lastQuery = '';
  String? _lastCategory;
  double? _lastMinPrice;
  double? _lastMaxPrice;
  String _sortBy = '';

  String get searchQuery => _lastQuery;
  String? get selectedCategory => _lastCategory;
  double? get minPrice => _lastMinPrice;
  double? get maxPrice => _lastMaxPrice;
  String get sortBy => _sortBy;

  Set<String> extractCategories(List<Product> products) {
    return products
        .where((p) => p.category != null && p.category!.isNotEmpty)
        .map((p) => p.category!)
        .toSet();
  }

  void search(String query, List<Product> allProducts,
      {String? category, double? minPrice, double? maxPrice, String sortBy = ''}) {
    _lastQuery = query;
    _lastCategory = category;
    _lastMinPrice = minPrice;
    _lastMaxPrice = maxPrice;
    _sortBy = sortBy;
    _debounce?.cancel();
    if (query.trim().isEmpty && category == null && minPrice == null && maxPrice == null) {
      emit(SearchInitial());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      emit(SearchLoading());
      var results = allProducts.where((p) {
        final matchesQuery = query.trim().isEmpty ||
            (p.name?.toLowerCase().contains(query.toLowerCase()) ?? false);
        final matchesCategory = category == null ||
            (p.category?.toLowerCase() == category.toLowerCase());
        final price = (p.price ?? 0).toDouble();
        final matchesMin = minPrice == null || price >= minPrice;
        final matchesMax = maxPrice == null || price <= maxPrice;
        return matchesQuery && matchesCategory && matchesMin && matchesMax;
      }).toList();
      switch (sortBy) {
        case 'price_asc':
          results.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case 'price_desc':
          results.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        case 'newest':
          results.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
          break;
        case 'name_az':
          results.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
          break;
        case 'name_za':
          results.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
          break;
      }
      emit(SearchLoaded(results));
    });
  }

  void filterByCategory(String category, List<Product> allProducts) {
    search(_lastQuery, allProducts, category: category, minPrice: _lastMinPrice, maxPrice: _lastMaxPrice, sortBy: _sortBy);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
