import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../../constant/Errors/custom_error_widget.dart';
import '../../../../../cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'grid_cart.dart';

class BuildGridView extends StatelessWidget {
  const BuildGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAllProuductsCubit, GetAllProuductsState>(
      builder: (context, state) {
        if (state is GetAllProuductsSuccess) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: MasonryGridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              crossAxisSpacing: 20,
              itemCount: state.products.products?.products?.length ?? 0,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(2),
                child: DesignGridCard(
                  imageurl: state.products.products?.products![index].image,
                  price: state.products.products?.products![index].price,
                  name: state.products.products?.products![index].name,
                  index: index,
                ),
              ),
            ),
          );
        } else if (state is GetAllProuductsFailure) {
          return CustomErrorWidget(
            errMessage: state.errMessage,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
