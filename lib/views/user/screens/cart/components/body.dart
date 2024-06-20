import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/views/user/screens/cart/components/product_card.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetFromCartCubit, GetFromCartState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is GetFromCartLoading) {
          return const CircularProgressIndicator();
        } else if (state is GetFromCartSuccess) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: ListView.builder(
              itemCount: state.getProductFromCart.details?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    ProductCard(
                      img: state.getProductFromCart.details?[index].product
                              ?.image ??
                          "",
                      price: "23",
                      name: state.getProductFromCart.details?[index].product
                              ?.name ??
                          "",
                    ),
                  ],
                );
              },
            ),
          );
        } else if (state is GetFromCartFailure) {
          return CustomErrorWidget(errMessage: state.errMessage);
        } else {
          return const Text("something error");
        }
      },
    );
  }
}
