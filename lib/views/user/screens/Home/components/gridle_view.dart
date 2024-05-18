import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ship_link/cubitallProducts/cubit.dart';
import 'package:ship_link/cubitallProducts/product_stat.dart';

import 'grid_cart.dart';

class BuildGridView extends StatelessWidget {
  const BuildGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = ProductCubit.get(context);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MasonryGridView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            crossAxisSpacing: 20,
            itemCount: cubit.allProducts.products?.products?.length ?? 0,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(2),
              child: DesignGridCard(
                model: cubit.allProducts.products?.products ?? [],
                index: index,
              ),
            ),
          ),
        );
      },
    );
  }
}
