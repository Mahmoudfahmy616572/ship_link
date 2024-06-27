import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';

import '../../../../shared/app_style.dart';
import '../../../../shared/build_elevation_button.dart';

class ButtomNavBar extends StatelessWidget {
  ButtomNavBar({
    super.key,
  });
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: InkWell(
        onTap: () {},
        child: SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 16),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            filled: true,
                            fillColor: const Color(0xFF242424),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: BorderSide.none),
                            hintText: 'Enter your promo code',
                            hintStyle:
                                const TextStyle(color: Color(0xFF999999))),
                      ),
                    ),
                    Positioned(
                        top: 15,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 45,
                            height: 49,
                            decoration: BoxDecoration(
                                color: const Color(0xFFA1A1A1),
                                borderRadius: BorderRadius.circular(9)),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ),
                        )),
                  ],
                ),
                BlocConsumer<GetFromCartCubit, GetFromCartState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is GetFromCartSuccess) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style:
                                  appStyle(18, FontWeight.w600, Colors.black),
                            ),
                            Text(
                              "\$ ${state.getProductFromCart.cart?.totalPrice ?? ""}",
                              style:
                                  appStyle(18, FontWeight.w600, Colors.black),
                            )
                          ],
                        ),
                      );
                    } else if (state is GetFromCartLoading) {
                      return const Text(".....");
                    } else if (state is GetFromCartFailure) {
                      return Text(state.errMessage);
                    } else {
                      return const CustomErrorWidget(
                        errMessage: "0",
                      );
                    }
                  },
                ),
                BlocBuilder<GetFromCartCubit, GetFromCartState>(
                  builder: (context, state) {
                    if (state is GetFromCartSuccess) {
                      return CheckoutButton(
                        text: 'Submit Order',
                        id: state.getProductFromCart.cart?.id ?? 0,
                      );
                    } else if (state is GetFromCartLoading) {
                      return const Text(".....");
                    } else if (state is GetFromCartFailure) {
                      return Text(state.errMessage);
                    } else {
                      return const CustomErrorWidget(
                        errMessage: "0",
                      );
                    }
                  },
                ),
                // const SizedBox(
                //   height: 20,
                // ),
                // BlocConsumer<ConfirmCartCubit, ConfirmCartState>(
                //   listener: (context, state) {
                //     if (state is ConfirmCartLoading) {
                //       isLoading = true;
                //     } else if (state is ConfirmCartFailure) {
                //       isLoading = false;
                //       CustomSnackBar.displayErrorMotionToast(
                //           state.errMessage, context);
                //     } else if (state is ConfirmCartSuccess) {
                //       isLoading = false;

                //       CustomSnackBar.displaySuccessMotionToast(
                //           state.confirmCart.success ?? "", context);
                //     }
                //   },
                //   builder: (context, state) {
                //     return ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         foregroundColor: Colors.white,
                //         backgroundColor: const Color(0xFF242424),
                //         textStyle: appStyle(18, FontWeight.w500, Colors.black),
                //         shape: const RoundedRectangleBorder(
                //             borderRadius:
                //                 BorderRadius.all(Radius.circular(10))),
                //       ),
                //       onPressed: () async {},
                //       child: isLoading
                //           ? const Center(child: CircularProgressIndicator())
                //           : const Text(
                //               "Check Out",
                //             ),
                //     );
                //   },
                // ),
              ],
            )),
      ),
    );
  }
}
