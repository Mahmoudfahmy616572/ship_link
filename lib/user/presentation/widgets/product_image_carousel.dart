import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double aspectRatio;
  final double borderRadius;

  const ProductImageCarousel({
    super.key,
    required this.imageUrls,
    this.aspectRatio = 1.4,
    this.borderRadius = 12,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final _currentPage = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(Icons.image, color: Color(0xFF9CA3AF)),
      );
    }
    if (urls.length == 1) {
      return _buildImage(urls[0]);
    }
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -30) {
          _currentPage.value = (_currentPage.value + 1) % urls.length;
        } else if (velocity > 30) {
          _currentPage.value = (_currentPage.value - 1 + urls.length) % urls.length;
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildImage(urls[_currentPage.value], key: ValueKey(_currentPage.value)),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, page, _) => Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${page + 1}/${urls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, {Key? key}) {
    return CachedNetworkImage(
      key: key,
      fit: BoxFit.cover,
      imageUrl: url,
      memCacheWidth: 400,
      memCacheHeight: 400,
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey[800],
        child: const Icon(Icons.image, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}
