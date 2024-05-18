import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubitallProducts/cubit.dart';
import 'package:ship_link/cubitallProducts/product_stat.dart';

import '../../../../../models/Cart/cart.dart';
import '../../../../shared/app_style.dart';
import '../../favourite/Components/button_shopping.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.cart,
    required this.index,
  });
  final List<Detail>? cart;
  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 120,
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF606060)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child:
                            Image.network(cart?[index].product?.image ?? "")),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${cart?[index].product?.name ?? ""}",
                          style: appStyle(
                              17, FontWeight.w500, const Color(0xFF606060)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "23",
                          style: appStyle(17, FontWeight.w500, Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Text("  "),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ButtonDeleteproduct(),
                  SizedBox(
                    height: 35,
                  ),
                  ButtonShoppingbag(),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
