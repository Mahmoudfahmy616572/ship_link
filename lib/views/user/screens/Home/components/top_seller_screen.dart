import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ship_link/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/views/user/screens/Home/components/grid_cart_top_seller.dart';

import '../../../../../constant/Errors/custom_error_widget.dart';

class TopSellerScreen extends StatelessWidget {
  const TopSellerScreen({super.key});
  static String routName = '/TopSellerPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDCDCD),
        title: const Text("Top Seller Products"),
      ),
      body: BlocBuilder<GetTopSellerCubit, GetTopSellerState>(
        builder: (context, state) {
          if (state is GetTopSellerSuccess) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                crossAxisSpacing: 20,
                itemCount: state.getTopSeller.topSellers?.length ?? 0,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(2),
                  child: DesignGridCard(
                    imageurl: state.getTopSeller.topSellers?[index].image,
                    name: state.getTopSeller.topSellers?[index].name,
                    index: index,
                    price: state.getTopSeller.topSellers?[index].price,
                  ),
                ),
              ),
            );
          } else if (state is GetTopSellerFailure) {
            return CustomErrorWidget(
              errMessage: state.errMessage,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
