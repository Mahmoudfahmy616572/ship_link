import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/views/user/screens/Home/components/category_container.dart';

class BuildCategoryMainRow extends StatelessWidget {
  const BuildCategoryMainRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: BlocBuilder<GetTopSellerCubit, GetTopSellerState>(
          builder: (context, state) {
            if (state is GetTopSellerLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GetTopSellerSuccess) {
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.getTopSeller.topSellers?.length,
                  itemBuilder: ((context, index) {
                    return SizedBox(
                        width: 200,
                        height: 100,
                        child: BuildCategoryContainer(
                          img:
                              state.getTopSeller.topSellers?[index].image ?? "",
                        ));
                  }));
            } else if (state is GetTopSellerFailure) {
              return CustomErrorWidget(
                errMessage: state.errMessage,
              );
            } else {
              return const CustomErrorWidget(errMessage: "Error");
            }
          },
        ));
  }
}
