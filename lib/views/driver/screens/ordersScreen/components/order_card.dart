// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubitDriver/acceptOrder/accept_order_cubit.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';

import '../../../../shared/app_style.dart';
import '../../../../shared/snackBar/snack_bar.dart';

class OrdersCard extends StatelessWidget {
  OrdersCard({
    super.key,
    required this.status,
    required this.totalPrice,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.index,
  });
  final String status;
  final String totalPrice;
  final String name;
  final String email;
  final String phoneNumber;
  bool isChecked = false;
  bool isLoading = false;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: MediaQuery.of(context).size.height * 0.01),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.92,
          height: MediaQuery.of(context).size.height * 0.32,
          decoration: const BoxDecoration(
              color: Color(0xFF545454),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white60,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "status:",
                          style: appStyle(20, FontWeight.w700, Colors.black),
                        ),
                        TextWidget(
                          text: status,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Total Price:",
                          style: appStyle(20, FontWeight.w700, Colors.black),
                        ),
                        TextWidget(
                          text: totalPrice,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextWidget(
                text: name,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              TextWidget(
                text: phoneNumber,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              TextWidget(
                text: email,
                color: Colors.black,
              ),
              const SizedBox(
                height: 20,
              ),
              BlocConsumer<AcceptOrderCubit, AcceptOrderState>(
                listener: (context, state) {
                  if (state is AcceptOrderSuccess) {
                    BlocProvider.of<GetOrdersCubit>(context).getOrder();
                    CustomSnackBar.displaySuccessMotionToast(
                        state.acceptOrder.message ?? "", context);
                    isLoading = false;
                  } else if (state is AcceptOrderFailure) {
                    if (state.errMessage ==
                        'Selected order has been accepted') {
                      BlocProvider.of<GetOrdersCubit>(context).getOrder();
                      CustomSnackBar.displaySuccessMotionToast(
                          "Selected order has been accepted", context);
                    } else {
                      CustomSnackBar.displayErrorMotionToast(
                          state.errMessage, context);
                    }

                    isLoading = false;
                  } else if (state is AcceptOrderLoading) {
                    isLoading = true;
                  }
                },
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.red)),
                            onPressed: () {},
                            child: const Text(
                              "Reject",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: BlocBuilder<GetOrdersCubit, GetOrdersState>(
                            builder: (context, state) {
                              if (state is GetOrdersSuccess) {
                                return ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.green)),
                                  onPressed: () {
                                    BlocProvider.of<AcceptOrderCubit>(context)
                                        .acceptOrders(
                                            orderId: state.getOrder.data
                                                ?.order?[index].id);
                                  },
                                  child: isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                          "Accept",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                );
                              } else {
                                return const Center(
                                  child: CustomErrorWidget(
                                      errMessage: "something Error"),
                                );
                              }
                            },
                          )),
                    ],
                  );
                },
              )
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        )
      ],
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Text(
        text,
        style: appStyle(15, FontWeight.normal, const Color(0xFFCDCDCD)),
      ),
    );
  }
}
