import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubitDriver/get_user_driver_data/get_userdriver_data_cubit.dart';

import '../../../../../constant/Errors/custom_error_widget.dart';
import '../../../../shared/app_style.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetUserdriverDataCubit, GetUserdriverDataState>(
      builder: (context, state) {
        if (state is GetUserdriverDataLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is GetUserdriverDataFailure) {
          return CustomErrorWidget(
            errMessage: state.errMessage,
          );
        } else if (state is GetUserdriverDataSuccess) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/mahmoud.jpg"),
                  radius: 45,
                ),
                const SizedBox(
                  width: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          state.getuserDriverData.data?.email ?? "",
                          style: appStyle(
                            16,
                            FontWeight.bold,
                            const Color(0xFF000000),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          'Phone Number : +2${state.getuserDriverData.data?.phoneNumber ?? "0**********"}',
                          style: appStyle(
                              16, FontWeight.normal, const Color(0xFF000000)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return const CustomErrorWidget(
            errMessage: "someThing error please try again later",
          );
        }
      },
    );
  }
}
