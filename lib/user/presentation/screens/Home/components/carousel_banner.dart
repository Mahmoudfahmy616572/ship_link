import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/user/presentation/screens/product/product_screen.dart';
import 'package:ship_link/core/widgets/app_style.dart';

class CarouselBanner extends StatefulWidget {
  final List<Product> products;
  const CarouselBanner({super.key, required this.products});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  late PageController _pageController;
  late Timer _timer;
  final _currentPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (widget.products.isEmpty) return;
      final next = (_currentPage.value + 1) % widget.products.length;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final height = screenWidth * 0.45;

    if (widget.products.isEmpty) {
      return SizedBox(height: height);
    }

    final discounts = [30, 15, 10];

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => _currentPage.value = i,
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              final discount = discounts[index % discounts.length];
              return _BannerCard(product: product, discount: discount);
            },
          ),
        ),
        SizedBox(height: 10.h),
        ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (context, currentPage, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.products.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: currentPage == i ? 24.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: currentPage == i ? AppColors.cta : AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Product product;
  final int discount;
  const _BannerCard({required this.product, required this.discount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(product: product))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: product.image ?? "", fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[800])),
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
                    SizedBox(height: 4.h),
                    Text(context.t.tr('up_to_off').replaceAll('%', '$discount'), style: appStyle(26, FontWeight.w800, Colors.white)),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(color: AppColors.cta, borderRadius: BorderRadius.circular(20.r)),
                      child: Text(context.t.tr('shop_now'), style: appStyle(12, FontWeight.w600, Colors.white)),
                    ),
                  ],
                ),
              ),
              Positioned(bottom: 12, right: 12, child: Text(product.name ?? "", style: appStyle(12, FontWeight.w400, Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }
}
