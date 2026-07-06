import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';

String _categoryLocaleKey(String category) {
  return 'category_' + category
      .toLowerCase()
      .replaceAll("'", '')
      .replaceAll(RegExp(r'[\s-]+'), '_');
}

String _categoryDisplayName(BuildContext context, String category) {
  final key = _categoryLocaleKey(category);
  final translated = context.t.tr(key);
  return translated == key
      ? category[0].toUpperCase() + category.substring(1)
      : translated;
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

class FavouriteBrands extends StatelessWidget {
  const FavouriteBrands({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final tileSize = (MediaQuery.of(context).size.width - 60) / 4;

    return SizedBox(
      height: tileSize * 1.3 + 4.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () => onCategoryTap(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: tileSize,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cta : AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.cta : AppColors.divider,
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
                    size: tileSize * 0.4,
                    color: isSelected ? Colors.white : AppColors.cta,
                  ),
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      _categoryDisplayName(context, category),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
