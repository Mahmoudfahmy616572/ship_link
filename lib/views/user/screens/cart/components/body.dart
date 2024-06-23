import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/views/user/screens/cart/components/buttom_nav_bar.dart';

import 'slidable_delete_From_cart.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetFromCartCubit, GetFromCartState>(
      listener: (context, state) {
        if (state is DeleteFromCartSuccess) {
          BlocProvider.of<GetFromCartCubit>(context).getProductFromCart();
        }
      },
      builder: (context, state) {
        if (state is GetFromCartLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetFromCartSuccess) {
          if (state.getProductFromCart.details != null) {
            return Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 500,
                    child: ListView.builder(
                      itemCount: state.getProductFromCart.details?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            SlidableDeleteFromCart(
                              model: state.getProductFromCart,
                              index: index,
                              img: state.getProductFromCart.details?[index]
                                      .product?.image ??
                                  "",
                              name: state.getProductFromCart.details?[index]
                                      .product?.name ??
                                  "",
                              price:
                                  "${state.getProductFromCart.details?[index].product?.price}",
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const ButtomNavBar()
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('your Cart is Empty'),
            );
          }
        } else if (state is GetFromCartFailure) {
          return Center(child: CustomErrorWidget(errMessage: state.errMessage));
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
