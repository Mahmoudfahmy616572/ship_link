import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubitDriver/get_user_driver_data/get_userdriver_data_cubit.dart';

import '../../../../cubitDriver/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'components/body.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  static String routName = '/ProfileDriver';

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  void initState() {
    BlocProvider.of<GetAcceptedOrderCubit>(context).getAcceptedOrder();
    BlocProvider.of<GetUserdriverDataCubit>(context).getuserDriverData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFEBEBEB),
      body: Body(),
    );
  }
}
