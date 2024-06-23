// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';

class AddToCartIcon extends StatefulWidget {
  AddToCartIcon({
    super.key,
    required this.id,
  });
  final int id;

  @override
  State<AddToCartIcon> createState() => _AddToCartIconState();
}

class _AddToCartIconState extends State<AddToCartIcon> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddToCartCubit, AddToCartState>(
      listener: (context, state) {
        if (state is AddToCartLoading) {
          isLoading = true;
        } else if (state is AddToCartSuccess) {
          isLoading = false;
          displaySuccessMotionToast(state.success);
        } else if (state is AddToCartFailure) {
          isLoading = false;
          displayErrorMotionToast(state.errMessage);
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
                BlocProvider.of<AddToCartCubit>(context)
                    .addToCart(id: widget.id);
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

  displayErrorMotionToast(String err) {
    MotionToast.error(
      title: const Text(
        'Error',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(err),
      position: MotionToastPosition.top,
      barrierColor: Colors.black.withOpacity(0.3),
      width: 300,
      height: 80,
      dismissable: false,
    ).show(context);
  }

  displaySuccessMotionToast(String description) {
    MotionToast toast = MotionToast.success(
      description: Text(
        description,
        style: const TextStyle(fontSize: 12),
      ),
      dismissable: true,
      opacity: .5,
    );
    toast.show(context);
  }
}
