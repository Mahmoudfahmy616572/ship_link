import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';

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
          return ListView.builder(
            itemCount: state.getOrder.data?.order?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return OrdersCard(
                totalPrice:
                    "${state.getOrder.data?.order?[index].totalPrice ?? ""}",
                status: state.getOrder.data?.order?[index].status ?? "",
                name:
                    "${state.getOrder.data?.order?[index].user?.firstName ?? ""}${state.getOrder.data?.order?[index].user?.lastName ?? ""}",
                email: state.getOrder.data?.order?[index].user?.email ?? "",
                phoneNumber:
                    state.getOrder.data?.order?[index].user?.phoneNumber ?? "",
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
