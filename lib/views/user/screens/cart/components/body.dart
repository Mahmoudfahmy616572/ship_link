import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../cubitallProducts/cubit.dart';
import '../../../../../cubitallProducts/product_stat.dart';
import 'product_card.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = ProductCubit.get(context);
        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: ListView.builder(
            itemCount: cubit.getCart.details?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  ProductCard(
                    cart: cubit.getCart.details ?? [],
                    index: index,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
