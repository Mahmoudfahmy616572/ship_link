import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/views/user/screens/product/product_screen.dart';

import '../../../../shared/app_style.dart';
import 'add_to_cart_Icon.dart';

class DesignGridCard extends StatelessWidget {
  const DesignGridCard({
    super.key,
    required this.imageurl,
    this.price,
    required this.name,
    required this.index,
    this.description,
  });
  final String? imageurl;
  final int? price;
  final String? name;
  final int index;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetAllProuductsCubit, GetAllProuductsState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is GetAllProuductsSuccess) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => ProductScreen(index: index))));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: AspectRatio(
                        aspectRatio: 1.5 / 1.9,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: imageurl!,
                          errorWidget: (context, url, error) => const Center(
                              child: Icon(
                            Icons.error_outline,
                            size: 60,
                          )),
                        ),
                      ),
                    ),
                    AddToCartIcon(
                      id: state.products.products?.products?[index].id ?? 0,
                    ),
                  ],
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "$name\n",
                      style: appStyle(17, FontWeight.w400, Colors.white)),
                  TextSpan(
                      text: "\$$price\n",
                      style: appStyle(18, FontWeight.w600, Colors.white)),
                ]))
              ],
            ),
          );
        } else if (state is GetAllProuductsFailure) {
          return CustomErrorWidget(
            errMessage: state.errMessage,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
