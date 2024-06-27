import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';

import 'components/custom_button.dart';

class CheckOutPage extends StatelessWidget {
  CheckOutPage({super.key});
  bool isLoading = false;
  static String routName = '/checkOutPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CheckOut"),
        backgroundColor: const Color(0xFFCDCDCD),
      ),
      backgroundColor: const Color(0xFFCDCDCD),
      body: BlocBuilder<ConfirmCartCubit, ConfirmCartState>(
        builder: (context, state) {
          if (state is ConfirmCartSuccess) {
            int totalPrice = state.confirmCart.order?.totalPrice ?? 0;
            return SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        SvgPicture.asset("assets/icons/cartCheckout.svg"),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RowPrice(
                              text: "Order Subtotal:",
                              price:
                                  "£ ${state.confirmCart.order?.totalPrice ?? 0}",
                            ),
                            const RowPrice(
                              text: "Discount:",
                              price: "£ 0",
                            ),
                            RowPrice(
                              text: "Total:",
                              price:
                                  "£ ${state.confirmCart.order?.totalPrice ?? 0}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  CustomButton(totalPrice: totalPrice),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text("something error"),
            );
          }
        },
      ),
    );
  }
}
