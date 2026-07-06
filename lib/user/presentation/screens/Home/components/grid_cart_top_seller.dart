import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/Errors/custom_error_widget.dart';
import 'package:ship_link/user/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/user/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/user/presentation/screens/product/product_screen.dart';
import 'package:ship_link/user/presentation/widgets/product_image_carousel.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';

import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';

class DesignGridCard extends StatefulWidget {
  const DesignGridCard({
    super.key,
    required this.productId,
    required this.index,
    this.isTall = false,
  });
  final int? productId;
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
    final allProducts = context.read<GetAllProuductsCubit>().state;
    Product? product;
    if (allProducts is GetAllProuductsSuccess) {
      final list = allProducts.products.products?.products ?? [];
      if (widget.productId != null) {
        product = list.cast<Product?>().firstWhere(
              (p) => p?.id == widget.productId,
              orElse: () => null,
            );
      }
      if (product == null && widget.index < list.length) {
        product = list[widget.index];
      }
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _PressScale(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
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
                    child: ProductImageCarousel(
                      imageUrls: product?.imageList ?? [],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
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

class _CartButton extends StatefulWidget {
  final Product product;
  final bool Function(GetFromCartState state, int productId) isInCart;

  const _CartButton({required this.product, required this.isInCart});

  @override
  State<_CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<_CartButton> {
  final _optimisticAdd = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _optimisticAdd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _optimisticAdd,
      builder: (context, optimistic, _) {
        final realInCart = context.select<GetFromCartCubit, bool>(
          (c) => widget.isInCart(c.state, widget.product.id ?? 0),
        );
        final showCheck = realInCart || optimistic;

        return GestureDetector(
          onTap: () async {
            if (showCheck) {
              final cartState = context.read<GetFromCartCubit>().state;
              if (cartState is GetFromCartSuccess) {
                final detail = cartState.getProductFromCart.details
                    ?.where((d) => d.product?.id == widget.product.id)
                    .firstOrNull;
                if (detail != null) {
                  _optimisticAdd.value = false;
                  if (!context.mounted) return;
                  context.read<GetFromCartCubit>().deleteFromCart(
                        cart_id: detail.id ?? 0,
                        product_id: widget.product.id ?? 0,
                      );
                  return;
                }
              }
              if (optimistic) {
                _optimisticAdd.value = false;
                await context.read<GetFromCartCubit>().getProductFromCart();
                if (!context.mounted) return;
                final newState = context.read<GetFromCartCubit>().state;
                if (newState is GetFromCartSuccess) {
                  final newDetail = newState.getProductFromCart.details
                      ?.where((d) => d.product?.id == widget.product.id)
                      .firstOrNull;
                  if (newDetail != null) {
                    context.read<GetFromCartCubit>().deleteFromCart(
                          cart_id: newDetail.id ?? 0,
                          product_id: widget.product.id ?? 0,
                        );
                  }
                }
              }
            } else {
              _optimisticAdd.value = true;
              await context
                  .read<AddToCartCubit>()
                  .addToCart(id: widget.product.id ?? 0);
              if (!context.mounted) return;
              if (context.read<AddToCartCubit>().state is AddToCartFailure) {
                _optimisticAdd.value = false;
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: 28.h,
            decoration: BoxDecoration(
              color: showCheck ? AppColors.success : AppColors.cta,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  showCheck ? Icons.check : Icons.add,
                  key: ValueKey('cart_$showCheck'),
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
