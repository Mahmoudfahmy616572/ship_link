import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../cubitallProducts/cubit.dart';
import '../../../../../cubitallProducts/product_stat.dart';
import '../../../../../models/allProducts/all_products.dart';
import '../../../../shared/app_style.dart';
import '../../product/product_screen.dart';

class DesignGridCard extends StatelessWidget {
  const DesignGridCard({
    super.key,
    required this.index,
    this.model,
  });
  final int index;
  final List<Product>? model;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is AddSuccess) {
          final snackBar = SnackBar(
            duration: const Duration(milliseconds: 1000),
            content: Text(state.success),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        if (state is GetSingleProductSuccess) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProductScreen()));
        }
        if (state is GetCartSuccess) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProductScreen()));
        }
      },
      builder: (context, state) {
        var cubit = ProductCubit.get(context);
        return GestureDetector(
          onTap: () {
            cubit.singleProduct(model?[index].id ?? 0);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    color: Colors.transparent,
                    height: 240,
                    width: 190,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        model?[index].image ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFF606066),
                          borderRadius: BorderRadius.circular(9)),
                      child: GestureDetector(
                        onTap: () {
                          cubit.addProductToCard(
                              id: " ${model?[index].id ?? ""}");
                        },
                        child: SvgPicture.asset(
                          "assets/icons/shopping_bag icon.svg",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: "${model?[index].name}\n",
                    style: appStyle(17, FontWeight.w400, Colors.white)),
                TextSpan(
                    text: "\$${model?[index].price}\n",
                    style: appStyle(18, FontWeight.w600, Colors.white))
              ]))
            ],
          ),
        );
      },
    );
  }
}
