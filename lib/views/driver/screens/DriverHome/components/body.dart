import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubitDriver/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'cancel_btn.dart';
import 'card_order_accepted.dart';
import 'custom_btn.dart';
import 'profile_info.dart';

List<String> listVehicleType = <String>['Motorcycle', 'Bike', 'Car'];
List<String> listRequist = <String>[
  'ID:4526548625',
  'Address: Cairo',
  'customer Name: Oliver',
  "Customer Number: +20**********",
  " Time: 4pm",
  "Date: 25-May-2024"
];

class Body extends StatefulWidget {
  const Body({
    super.key,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String dropdownValueVehicleType = listVehicleType.first;
  String dropdownValuelistRequist = listRequist.first;

  bool isDroped = false;
  double height = 0;

  @override
  Widget build(BuildContext context) {
    double mediaqueryConstantWidth = MediaQuery.of(context).size.width;
    double mediaqueryConstantHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: mediaqueryConstantWidth * 0.025,
          vertical: mediaqueryConstantHeight * 0.06),
      height: mediaqueryConstantHeight,
      width: mediaqueryConstantWidth,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileInfo(),
            SizedBox(
              height: mediaqueryConstantHeight * 0.03,
            ), ///////////List to view accepted order/////////////////
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accepted Orders',
                    style: appStyle(20, FontWeight.normal, Colors.black)),
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaqueryConstantWidth * 0.037,
                        vertical: mediaqueryConstantHeight * 0.02),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadiusDirectional.circular(10)),
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: BlocBuilder<GetAcceptedOrderCubit,
                        GetAcceptedOrderState>(
                      builder: (context, state) {
                        if (state is GetAcceptedOrderLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is GetAcceptedOrderSuccess) {
                          return ListView.builder(
                              itemCount:
                                  state.getAcceptedOrder.data?.order?.length ??
                                      0,
                              itemBuilder: (context, index) {
                                return AcceptedOrderCard(
                                  status: state.getAcceptedOrder.data
                                          ?.order?[index].status ??
                                      "",
                                  name: state.getAcceptedOrder.data
                                          ?.order?[index].user?.firstName ??
                                      "",
                                  phoneNumber: state.getAcceptedOrder.data
                                          ?.order?[index].user?.phoneNumber ??
                                      "",
                                  totalPrice:
                                      '${state.getAcceptedOrder.data?.order?[index].totalPrice ?? ""}',
                                  email: state.getAcceptedOrder.data
                                          ?.order?[index].user?.email ??
                                      "",
                                );
                              });
                        } else if (state is GetAcceptedOrderFailure) {
                          return CustomErrorWidget(
                            errMessage: state.errMessage,
                          );
                        } else {
                          return const CustomErrorWidget(
                            errMessage: "something Error",
                          );
                        }
                      },
                    )),
              ],
            ),
            SizedBox(
              height: mediaqueryConstantHeight * 0.04,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vehicle Type',
                    style: appStyle(
                        16, FontWeight.normal, const Color(0xFF6C6B6B))),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.03,
                        right: MediaQuery.of(context).size.width * 0.05),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Colors.black),
                    child: dropdwonVehicleType()),
              ],
            ),
            SizedBox(
              height: mediaqueryConstantHeight * 0.04,
            ),
            SizedBox(
              height: mediaqueryConstantHeight * 0.04,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  isDroped = !isDroped;

                  isDroped
                      ? height = MediaQuery.of(context).size.height * 0.31
                      : height = 0;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "More Details",
                    style: appStyle(16, FontWeight.normal, Colors.black),
                  ),
                  isDroped
                      ? const Icon(Icons.arrow_drop_down_outlined)
                      : const Icon(Icons.arrow_right_outlined),
                ],
              ),
            ),
            SizedBox(
              height: mediaqueryConstantHeight * 0.03,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.fastOutSlowIn,
              width: MediaQuery.of(context).size.width,
              height: height,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: isDroped
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Another means of  communication: email...\n Shipment type: breakable\n Shipment: big",
                            style:
                                appStyle(16, FontWeight.normal, Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                          SvgPicture.asset(
                            "assets/icons/callAdmin.svg",
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                          Text(
                            "Call Admin",
                            style:
                                appStyle(16, FontWeight.normal, Colors.black),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.031,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CancelBtn(
                  icon: "assets/icons/cancel.svg",
                  width: 40,
                  height: 40,
                ),
                CustomBtn(
                  text: 'Process',
                  width: 167,
                  height: 45,
                ),
                CustomBtn(
                  text: 'Done',
                  width: 167,
                  height: 45,
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            )
          ],
        ),
      ),
    );
  }

  DropdownButton<String> dropdwonVehicleType() {
    return DropdownButton<String>(
      onTap: () {},
      value: dropdownValueVehicleType,
      borderRadius: BorderRadius.circular(15),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(color: Colors.white),
      style: appStyle(
          17,
          FontWeight.w700,
          const Color(
            0xFFCDCDCD,
          )),
      dropdownColor: const Color(0xFF6C6C6C),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValueVehicleType = value!;
        });
        // switch (value) {
        //   case "User":
        //     Navigator.pushNamed(context, UserRegister.routName);
        //     break;
        //   case "Driver":
        //     Navigator.pushNamed(context, DriverRegister.routName);
        //     break;
        //   case "Provider":
        //     Navigator.pushNamed(context, ProviderRegister.routName);

        //     break;
        // }
      },
      items: listVehicleType.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  DropdownButton<String> dropdwonRequest() {
    return DropdownButton<String>(
      onTap: () {},
      value: dropdownValuelistRequist,
      borderRadius: BorderRadius.circular(15),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(color: Colors.white),
      style: appStyle(
          17,
          FontWeight.w700,
          const Color(
            0xFFCDCDCD,
          )),
      dropdownColor: Colors.black,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValuelistRequist = value!;
        });
        // switch (value) {
        //   case "User":
        //     Navigator.pushNamed(context, UserRegister.routName);
        //     break;
        //   case "Driver":
        //     Navigator.pushNamed(context, DriverRegister.routName);
        //     break;
        //   case "Provider":
        //     Navigator.pushNamed(context, ProviderRegister.routName);

        //     break;
        // }
      },
      items: listRequist.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
