import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/user/presentation/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/user/domain/repositories/favourite_repository.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/user/presentation/screens/product/product_screen.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';

class Favourite extends StatelessWidget {
  const Favourite({super.key});
  static String routName = '/favourite';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavouriteCubit(
        getIt.get<FavouriteRepository>(),
      )..getFavourites(),
      child: _FavouriteScreen(),
    );
  }
}

class _FavouriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(context.t.tr('my_favourites'), style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
      ),
      body: BlocBuilder<FavouriteCubit, FavouriteState>(
        builder: (context, state) {
          if (state is FavouriteLoading) {
            return ShimmerLoading.list();
          }
          if (state is FavouriteError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => context.read<FavouriteCubit>().getFavourites(),
                    child: Text(context.t.tr('retry')),
                  ),
                ],
              ),
            );
          }
          if (state is FavouriteLoaded && state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64.sp, color: AppColors.textHint),
                  SizedBox(height: 16.h),
                    Text(context.t.tr('no_favourites'), style: appStyle(16, FontWeight.w500, AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    Text(context.t.tr('tap_heart_to_save'),
                      style: appStyle(13, FontWeight.w400, AppColors.textHint)),
                ],
              ),
            );
          }
          if (state is FavouriteLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<FavouriteCubit>().getFavourites(),
              child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Dismissible(
                  key: Key('fav_${item.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.w),
                    color: AppColors.error.withAlpha(38),
                    child: const Icon(Icons.delete, color: AppColors.error),
                  ),
                  onDismissed: (_) => context.read<FavouriteCubit>().toggleFavourite(item.productId),
                  child: Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductScreen(
                            product: Product(
                              id: item.productId,
                              name: item.productName,
                              image: item.productImage,
                              price: item.productPrice,
                            ),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: CachedNetworkImage(
                                imageUrl: item.productImage ?? '',
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.border,
                                  child: const Icon(Icons.image, color: AppColors.textHint),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: appStyle(14, FontWeight.w500, AppColors.textPrimary)),
                                  SizedBox(height: 6.h),
                                  Text('\$${(item.productPrice ?? 0).toStringAsFixed(0)}',
                                      style: appStyle(16, FontWeight.w700, AppColors.cta)),
                                  if (item.productQty <= 0) ...[
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withAlpha(25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(context.t.tr('out_of_stock'),
                                          style: appStyle(11, FontWeight.w600, AppColors.error)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.productQty <= 0) ...[
                                  IconButton(
                                    icon: Icon(
                                      item.isWatching ? Icons.notifications_active : Icons.notifications_none,
                                      color: item.isWatching ? AppColors.cta : AppColors.textHint,
                                      size: 20,
                                    ),
                                    onPressed: () => context.read<FavouriteCubit>().toggleStockWatch(item.productId),
                                    tooltip: context.t.tr('notify_when_available'),
                                  ),
                                ],
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.textHint),
                                  onPressed: () => context.read<FavouriteCubit>().toggleFavourite(item.productId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
