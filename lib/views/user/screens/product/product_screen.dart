import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/cubits/getAllProducts/get_all_prouducts_cubit.dart';

import '../../../shared/app_style.dart';
import 'components/add_subtract_btn.dart';
import 'components/button_add_to_cart.dart';
import 'components/rating_row.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.index,
  });
  static String routName = '/productScreen';
  final int index;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  AddToCartCubit? addToCartCubit;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetAllProuductsCubit, GetAllProuductsState>(
      listener: (context, state) {
        if (state is AddToCartSuccess) {
          final snackBar = SnackBar(
            duration: const Duration(milliseconds: 1000),
            content: Text("state."),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      builder: (context, state) {
        if (state is GetAllProuductsSuccess) {
          return Scaffold(
              backgroundColor: const Color(0xFFD9D9D9),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AspectRatio(
                          aspectRatio: 2.3 / 1.9,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: state.products.products
                                    ?.products?[widget.index].image ??
                                "https://www.fonewalls.com/wp-content/uploads/2019/09/Error-Sign-Wallpaper-691x1536.jpg",
                            errorWidget: (context, url, error) => const Center(
                                child: Icon(
                              Icons.error_outline,
                              size: 60,
                            )),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.055,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${state.products.products?.products?[widget.index].price ?? 4}",
                            style: appStyle(22, FontWeight.w600, Colors.black),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.products.products?.products![widget.index]
                                        .name ??
                                    "",
                                style:
                                    appStyle(22, FontWeight.w600, Colors.black),
                              ),
                              Row(
                                children: [
                                  AddOrSubtractButton(
                                    ontap: () {},
                                    icon: Icons.add,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Text("01",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          letterSpacing: 2)),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  AddOrSubtractButton(
                                    ontap: () {},
                                    icon: Icons.remove,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const RaitingRow(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.09,
                          ),
                          BuildButtonAddToCart(
                            text: "Add to cart",
                            img: "assets/icons/saveIcon.svg",
                            // ontap: () {
                            //   addToCartCubit?.cartServeices.addToCart(state
                            //           .products
                            //           .products
                            //           ?.products?[widget.index]
                            //           .id ??
                            //       0);
                            // },
                            id: state.products.products?.products?[widget.index]
                                    .id ??
                                0,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ));
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
