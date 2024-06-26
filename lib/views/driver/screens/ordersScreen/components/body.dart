import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';
import 'package:ship_link/data/models/get_order/get_order.dart';

import 'order_card.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetOrdersCubit, GetOrdersState>(
      builder: (context, state) {
        if (state is GetOrdersLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is GetOrdersFailure) {
          return CustomErrorWidget(errMessage: state.errMessage);
        } else if (state is GetOrdersSuccess) {
          List<Order>? order = state.getOrder.data?.order
              ?.where((element) => element.status == "Pending")
              .toList();
          return ListView.builder(
            itemCount: order?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return OrdersCard(
                totalPrice: "${order?[index].totalPrice ?? ""}",
                status: order?[index].status ?? "",
                name:
                    "${order?[index].user?.firstName ?? ""}${state.getOrder.data?.order?[index].user?.lastName ?? ""}",
                email: order?[index].user?.email ?? "",
                phoneNumber: order?[index].user?.phoneNumber ?? "",
                index: index,
              );
            },
          );
        } else {
          return const Center(
            child: CustomErrorWidget(errMessage: "Try Again Later"),
          );
        }
      },
    );
  }
}
