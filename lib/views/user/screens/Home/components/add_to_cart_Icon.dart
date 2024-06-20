// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';

class AddToCartIcon extends StatelessWidget {
  AddToCartIcon({
    super.key,
    required this.id,
  });
  final int id;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddToCartCubit, AddToCartState>(
      listener: (context, state) {
        if (state is AddToCartLoading) {
          isLoading = true;
        } else if (state is AddToCartSuccess) {
          isLoading = false;
          final snackBar = SnackBar(
            duration: const Duration(milliseconds: 1000),
            content: Text(state.success),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is AddToCartFailure) {
          isLoading = false;
          final snackBar = SnackBar(
            duration: const Duration(milliseconds: 1000),
            content: Text(state.errMessage),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      builder: (context, state) {
        return Positioned(
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
                BlocProvider.of<AddToCartCubit>(context).addToCart(id: id);
              },
              child: SvgPicture.asset(
                "assets/icons/shopping_bag icon.svg",
              ),
            ),
          ),
        );
      },
    );
  }
}
