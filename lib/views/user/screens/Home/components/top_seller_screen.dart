import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';
import 'package:ship_link/views/user/screens/Home/components/grid_cart_top_seller.dart';

import '../../../../../constant/Errors/custom_error_widget.dart';

class TopSellerScreen extends StatelessWidget {
  const TopSellerScreen({super.key});
  static String routName = '/TopSellerPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(context.t.tr('top_seller_products')),
      ),
      body: BlocBuilder<GetTopSellerCubit, GetTopSellerState>(
        builder: (context, state) {
          if (state is GetTopSellerSuccess) {
            final sellers = state.getTopSeller.topSellers ?? [];
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(8.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, rowIndex) {
                        final leftIdx = rowIndex * 2;
                        final rightIdx = rowIndex * 2 + 1;
                        if (leftIdx >= sellers.length) {
                          return const SizedBox.shrink();
                        }
                        final leftP = sellers[leftIdx];
                        final rightP = rightIdx < sellers.length
                            ? sellers[rightIdx]
                            : null;
                        final leftTall = rowIndex % 2 == 0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: RepaintBoundary(
                                  child: DesignGridCard(
                                    key: ValueKey('ts_${leftP.id}'),
                                    productId: leftP.id,
                                    index: leftIdx,
                                    isTall: leftTall,
                                  ),
                                ),
                              ),
                              if (rightP != null) SizedBox(width: 10.w),
                              if (rightP != null)
                                Expanded(
                                  child: RepaintBoundary(
                                    child: DesignGridCard(
                                      key: ValueKey('ts_${rightP.id}'),
                                      productId: rightP.id,
                                      index: rightIdx,
                                      isTall: !leftTall,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      childCount: (sellers.length + 1) ~/ 2,
                    ),
                  ),
                ),
              ],
            );
          } else if (state is GetTopSellerFailure) {
            return CustomErrorWidget(
              errMessage: state.errMessage,
            );
          } else {
            return ShimmerLoading.horizontalScroll();
          }
        },
      ),
    );
  }
}
