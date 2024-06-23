// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';

import '../../../../shared/app_style.dart';

class BuildButtonAddToCart extends StatefulWidget {
  BuildButtonAddToCart({
    super.key,
    required this.text,
    required this.img,
    required this.id,
  });
  final String text;
  final String img;
  final int id;

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
        } else if (state is AddToCartSuccess) {
          isLoading = false;
          displaySuccessMotionToast(state.success);
        } else if (state is AddToCartFailure) {
          isLoading = false;
          displayErrorMotionToast(state.errMessage);
        }
      },
      builder: (context, state) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              print(widget.id);
              BlocProvider.of<AddToCartCubit>(context).addToCart(id: widget.id);
            },
            child: Container(
                width: MediaQuery.of(context).size.width * 0.76,
                height: 45,
                decoration: BoxDecoration(
                    color: const Color(0xFF242424),
                    borderRadius: BorderRadius.circular(12)),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: Text(
                          widget.text,
                          style: appStyle(20, FontWeight.w700, Colors.white),
                        ),
                      )),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: SvgPicture.asset(
                widget.img,
              )),
            ),
          )
        ],
      ),
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
