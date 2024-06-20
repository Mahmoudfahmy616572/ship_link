// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';

import '../../../../shared/app_style.dart';

class BuildButtonAddToCart extends StatelessWidget {
  BuildButtonAddToCart({
    super.key,
    required this.text,
    required this.img,
    required this.id,
  });
  final String text;
  final String img;
  bool isLoading = false;
  final int id;
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
      builder: (context, state) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              print(id);
              BlocProvider.of<AddToCartCubit>(context).addToCart(id: id);
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
                          text,
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
                img,
              )),
            ),
          )
        ],
      ),
    );
  }
}
