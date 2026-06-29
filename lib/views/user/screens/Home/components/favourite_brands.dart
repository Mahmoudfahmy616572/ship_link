import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';

class BrandInfo {
  final String name;
  final String imageAsset;
  final Color bgColor;
  final Set<String> categories;

  const BrandInfo({
    required this.name,
    required this.imageAsset,
    required this.bgColor,
    required this.categories,
  });
}

const List<BrandInfo> brands = [
  BrandInfo(
    name: "Apple",
    imageAsset: "assets/images/apple.png",
    bgColor: AppColors.surfaceAlt,
    categories: {"smartphones", "laptops"},
  ),
  BrandInfo(
    name: "Nike",
    imageAsset: "assets/images/nike.png",
    bgColor: AppColors.surfaceAlt,
    categories: {"mens-shoes", "mens-shirts", "tops"},
  ),
  BrandInfo(
    name: "BMW",
    imageAsset: "assets/images/bmw.png",
    bgColor: AppColors.surfaceAlt,
    categories: {"furniture", "home-decoration", "automotive"},
  ),
  BrandInfo(
    name: "Zara",
    imageAsset: "assets/images/zara.png",
    bgColor: AppColors.surfaceAlt,
    categories: {"womens-dresses", "womens-bags", "womens-shoes", "womens-jewellery"},
  ),
];

class FavouriteBrands extends StatelessWidget {
  const FavouriteBrands({
    super.key,
    required this.selectedCategories,
    required this.onBrandTap,
  });

  final Set<String> selectedCategories;
  final void Function(Set<String> categories) onBrandTap;

  @override
  Widget build(BuildContext context) {
    final tileSize = (MediaQuery.of(context).size.width - 48) / 4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: brands.map((brand) {
          final isSelected = selectedCategories == brand.categories;
          return GestureDetector(
            onTap: () => onBrandTap(brand.categories),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: tileSize,
              height: tileSize * 1.3,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cta : brand.bgColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: isSelected ? AppColors.cta : AppColors.divider, width: 1.5),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.cta.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    brand.imageAsset,
                    width: tileSize * 0.45,
                    errorBuilder: (_, __, ___) => Icon(Icons.business, size: tileSize * 0.4, color: Colors.white54),
                  ),
                  SizedBox(height: 6.h),
                  Text(brand.name, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 11.sp)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
