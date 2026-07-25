import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/web/data/models/allProducts/all_products.dart';
import 'package:ship_link/web/data/models/review/review_model.dart';
import 'package:ship_link/web/data/repositories/review_repository_impl.dart';
import 'package:ship_link/core/utils/sizer.dart';

class ProductDetailsWeb extends StatefulWidget {
  final Product product;
  const ProductDetailsWeb({super.key, required this.product});
  static String routName = '/product-details';

  @override
  State<ProductDetailsWeb> createState() => _ProductDetailsWebState();
}

class _ProductDetailsWebState extends State<ProductDetailsWeb> {
  final _reviewService = ReviewRepositoryImpl();
  List<Review> _reviews = [];
  double _avgRating = 0;
  int _reviewCount = 0;
  bool _reviewsLoading = true;
  final _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final product = widget.product;
    if (product.id == null) return;
    final rating = (await _reviewService.getProductRating(product.id!)).fold(
      (_) => <String, dynamic>{'avg': 0.0, 'count': 0}, (v) => v,
    );
    final reviews = (await _reviewService.getReviews(product.id!)).fold(
      (_) => <Review>[], (v) => v,
    );
    if (mounted) setState(() {
      _reviews = reviews;
      _avgRating = (rating['avg'] as num).toDouble();
      _reviewCount = rating['count'] as int;
      _reviewsLoading = false;
    });
  }

  void _showWriteReview() {
    int rating = 5;
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t.tr('write_review'), style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        icon: Icon(star <= rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFF59E0B), size: 36),
                        onPressed: () => setSheetState(() => rating = star),
                      );
                    }),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.t.tr('review_hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _reviewService.addReview(
                          productId: widget.product.id ?? 0,
                          rating: rating,
                          comment: commentCtrl.text.trim(),
                        );
                        _loadReviews();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.cta),
                      child: Text(context.t.tr('submit'), style: appStyle(16, FontWeight.w600, Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => _shareProduct(context),
            icon: const Icon(Icons.share_outlined),
            tooltip: context.t.tr('share'),
          ),
          Builder(builder: (context) {
            final pid = product.id ?? 0;
            final isFav = context.select<FavouriteCubit, bool>((c) => c.isFavourite(pid));
            return IconButton(
              onPressed: () => context.read<FavouriteCubit>().toggleFavourite(pid),
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(product),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${context.t.tr('egp')} ${product.price?.toStringAsFixed(0) ?? '0'}',
                      style: appStyle(28, FontWeight.w700, AppColors.cta)),
                  SizedBox(height: 12),
                  Text(product.name ?? '', style: appStyle(22, FontWeight.w600, const Color(0xFF111827))),
                  SizedBox(height: 8),
                  Text(product.description ?? '', style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                  SizedBox(height: 16),
                  _ratingRow(),
                  SizedBox(height: 20),
                  _quantitySection(),
                  SizedBox(height: 24),
                  _buildReviewsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(Product product) {
    final images = product.imageList;
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: AspectRatio(
            aspectRatio: 1,
            child: images.isEmpty
                ? Container(color: const Color(0xFFF3F4F6), child: const Center(child: Icon(Icons.image, size: 64, color: Color(0xFFD1D5DB))))
                : Stack(
                    children: [
                      PageView.builder(
                        controller: _pageCtrl,
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (_, i) => Padding(
                          padding: EdgeInsets.all(20),
                          child: Image.network(images[i], fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(Icons.image, size: 64, color: const Color(0xFFD1D5DB)),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 16, left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              width: _currentPage == i ? 20 : 8, height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == i ? AppColors.cta : const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _ratingRow() {
    return Row(
      children: [
        ...List.generate(5, (i) => Icon(
          i < _avgRating.round() ? Icons.star : Icons.star_border,
          size: 20, color: const Color(0xFFF59E0B),
        )),
        SizedBox(width: 8),
        Text('$_avgRating ($_reviewCount)', style: appStyle(14, FontWeight.w500, const Color(0xFF6B7280))),
      ],
    );
  }

  Widget _quantitySection() {
    return BlocBuilder<AddToCartCubit, AddToCartState>(
      builder: (context, state) {
        final cubit = context.read<AddToCartCubit>();
        return Column(
          children: [
            Row(
              children: [
                Text(context.t.tr('quantity'), style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
                const Spacer(),
                _qtyBtn(Icons.remove, () => cubit.decrementQuantity()),
                SizedBox(width: 16),
                Text(cubit.pendingQuantity.toString().padLeft(2, '0'), style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
                SizedBox(width: 16),
                _qtyBtn(Icons.add, () => cubit.incrementQuantity()),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: state is AddToCartLoading ? null : () => cubit.addToCart(id: product.id, quantity: cubit.pendingQuantity),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: state is AddToCartLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.t.tr('add_to_cart'), style: appStyle(16, FontWeight.w600, Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF111827)),
      ),
    );
  }

  Product get product => widget.product;

  void _shareProduct(BuildContext context) {
    final url = Uri.base.toString().split('?').first;
    final link = '$url?product=${product.id}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t.tr('link_copied')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.t.tr('reviews'), style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
            const Spacer(),
            if (_reviewCount > 0)
              Text('$_reviewCount ${context.t.tr('reviews')}', style: appStyle(13, FontWeight.w500, const Color(0xFF6B7280))),
          ],
        ),
        SizedBox(height: 12),
        if (_reviewsLoading)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_reviews.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.rate_review_outlined, size: 40, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 8),
                  Text(context.t.tr('no_reviews_yet'), style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                ],
              ),
            ),
          )
        else
          ..._reviews.take(3).map((r) => _reviewCard(r)),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showWriteReview,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(context.t.tr('write_review')),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(Review review) {
    final name = review.user?['name'] as String? ?? 'Anonymous';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
              SizedBox(width: 8),
              Text(name, style: appStyle(13, FontWeight.w600, const Color(0xFF111827))),
              const Spacer(),
              Row(children: List.generate(5, (i) => Icon(
                i < review.rating ? Icons.star : Icons.star_border,
                size: 14, color: const Color(0xFFF59E0B),
              ))),
            ],
          ),
          if ((review.comment ?? '').isNotEmpty) ...[
            SizedBox(height: 6),
            Text(review.comment!, style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
          ],
        ],
      ),
    );
  }
}
