import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/views/user/screens/product/product_screen.dart';
import 'package:ship_link/data/models/allProducts/all_products.dart';
import 'package:ship_link/views/shared/product_image_carousel.dart';

import '../../../../shared/app_style.dart';

class DesignGridCard extends StatefulWidget {
  const DesignGridCard({
    super.key,
    required this.product,
    required this.index,
    this.isTall = false,
  });
  final Product? product;
  final int index;
  final bool isTall;

  @override
  State<DesignGridCard> createState() => _DesignGridCardState();
}

class _DesignGridCardState extends State<DesignGridCard>
    with SingleTickerProviderStateMixin {
  static final Set<int> _seen = {};
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    if (_seen.contains(widget.index)) {
      _entryCtrl.value = 1.0;
    } else {
      _seen.add(widget.index);
      Future.delayed(
          Duration(milliseconds: (widget.index % 10) * 30), () {
        if (mounted) _entryCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  static bool _isInCart(GetFromCartState state, int productId) {
    if (state is GetFromCartSuccess) {
      return state.getProductFromCart.details
              ?.any((d) => d.product?.id == productId) ??
          false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _PressScale(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProductScreen(product: product)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: AspectRatio(
                    aspectRatio: widget.isTall ? 0.9 : 1.3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ProductImageCarousel(
                          imageUrls: product?.imageList ?? [],
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _FavButton(product: product),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product?.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appStyle(
                            13, FontWeight.w500, AppColors.textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "\$${product?.price?.toStringAsFixed(0) ?? "0"}",
                        style: appStyle(15, FontWeight.w700, AppColors.cta),
                      ),
                      SizedBox(height: 6.h),
                      if (product != null)
                        _CartButton(product: product, isInCart: _isInCart),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _anim = Tween<double>(begin: 1.0, end: 0.93).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Listener(
        onPointerDown: (_) => _ctrl.forward(),
        onPointerUp: (_) {
          if (_ctrl.value > 0) _ctrl.reverse();
        },
        onPointerCancel: (_) {
          if (_ctrl.value > 0) _ctrl.reverse();
        },
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, child) =>
              Transform.scale(scale: _anim.value, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  final Product? product;
  const _FavButton({this.product});

  @override
  Widget build(BuildContext context) {
    final pid = product?.id ?? 0;
    final isFav =
        context.select<FavouriteCubit, bool>((c) => c.isFavourite(pid));

    return GestureDetector(
      onTap: () => context.read<FavouriteCubit>().toggleFavourite(pid),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_outline_rounded,
            key: ValueKey(isFav),
            size: 15.sp,
            color: isFav ? Colors.redAccent : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatefulWidget {
  final Product product;
  final bool Function(GetFromCartState state, int productId) isInCart;

  const _CartButton({required this.product, required this.isInCart});

  @override
  State<_CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<_CartButton> {
  bool _optimisticAdd = false;

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<GetFromCartCubit>().state;
    final inCart =
        widget.isInCart(cartState, widget.product.id ?? 0) || _optimisticAdd;

    return GestureDetector(
      onTap: () async {
        if (inCart && !_optimisticAdd) {
          final details = (cartState as GetFromCartSuccess)
              .getProductFromCart.details;
          final detail = details
              ?.where((d) => d.product?.id == widget.product.id)
              .firstOrNull;
          if (!context.mounted) return;
          context.read<GetFromCartCubit>().deleteFromCart(
                cart_id: detail?.id ?? 0,
                product_id: widget.product.id ?? 0,
              );
        } else {
          setState(() => _optimisticAdd = true);
          await context
              .read<AddToCartCubit>()
              .addToCart(id: widget.product.id ?? 0);
          if (!context.mounted) return;
          if (context.read<AddToCartCubit>().state is AddToCartFailure) {
            setState(() => _optimisticAdd = false);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 28.h,
        decoration: BoxDecoration(
          color: inCart ? AppColors.success : AppColors.cta,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              inCart ? Icons.check : Icons.add,
              key: ValueKey('cart_$inCart'),
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}
