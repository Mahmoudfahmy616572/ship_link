import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';

import '../../../../shared/app_style.dart';

class BuildButtonAddToCart extends StatefulWidget {
  const BuildButtonAddToCart({
    super.key,
    required this.text,
    required this.id,
    this.quantity = 1,
  });
  final String text;
  final int id;
  final int quantity;

  @override
  State<BuildButtonAddToCart> createState() => _BuildButtonAddToCartState();
}

class _BuildButtonAddToCartState extends State<BuildButtonAddToCart> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddToCartCubit, AddToCartState>(
      listener: (context, state) {
        if (state is AddToCartLoading) {
          isLoading = true;
        } else if (state is AddToCartSuccess || state is AddToCartFailure) {
          isLoading = false;
        }
      },
      builder: (context, state) => InkWell(
        onTap: () {
          BlocProvider.of<AddToCartCubit>(context)
              .addToCart(id: widget.id, quantity: widget.quantity);
        },
        child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
                color: AppColors.cta,
                borderRadius: BorderRadius.circular(14)),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Center(
                    child: Text(
                      widget.text,
                      style: appStyle(18, FontWeight.w700, Colors.white),
                    ),
                  )),
      ),
    );
  }
}
