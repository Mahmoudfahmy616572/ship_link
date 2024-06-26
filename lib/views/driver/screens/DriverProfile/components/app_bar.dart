import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/views/driver/screens/DriverSignIn/signin_driver.dart';
import 'package:ship_link/views/shared/text_field.dart';

import '../../../../../constant/Errors/custom_error_widget.dart';
import '../../../../../cubitDriver/get_user_driver_data/get_userdriver_data_cubit.dart';
import '../../../../../cubitDriver/upDateUserData/up_date_user_data_cubit.dart';
import '../../../../shared/app_style.dart';
import '../../../../shared/snackBar/snack_bar.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              var cubit = AuthCubit.get(context);
              return InkWell(
                  onTap: () {
                    cubit.signOutDriver();
                    CustomSnackBar.displaySuccessMotionToast(
                        "Logout Successfuly", context);
                    Navigator.pushReplacementNamed(
                        context, SignInDriver.routName);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "LogOut",
                      style: appStyle(15, FontWeight.w600, Colors.white),
                    ),
                  ));
            },
          ),
          Text(
            "Driver Profile",
            style: appStyle(18, FontWeight.w600, Colors.white),
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              AuthCubit.get(context);
              return InkWell(
                  onTap: () {
                    _dialogBuilder(context, false);
                  },
                  child: SvgPicture.asset(
                    "assets/icons/Editsvg.svg",
                  ));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, bool isLoading) {
    TextEditingController phoneController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Info'),
          content: BlocConsumer<GetUserdriverDataCubit, GetUserdriverDataState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is GetUserdriverDataSuccess) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        BuildTextField(
                          controller: nameController,
                          hintText: 'enter your name',
                          obscureText: false,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        BuildTextField(
                          controller: phoneController,
                          hintText: 'enter your PhoneNumber',
                          textInputType: TextInputType.phone,
                          obscureText: false,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const CustomErrorWidget(errMessage: "Error");
              }
            },
          ),
          actions: [
            BlocConsumer<UpDateUserDataCubit, UpDateUserDataState>(
              listener: (context, state) {
                if (state is UpDateUserDataILoading) {
                  isLoading = true;
                } else if (state is UpDateUserDataFailure) {
                  isLoading = false;
                  if (state.errMessage == 'Succes Update') {
                    BlocProvider.of<GetUserdriverDataCubit>(context)
                        .getuserDriverData();
                    CustomSnackBar.displaySuccessMotionToast(
                        "Update Info Successfully", context);
                  } else {
                    CustomSnackBar.displayErrorMotionToast(
                        state.errMessage, context);
                  }
                } else if (state is UpDateUserDataSuccess) {
                  isLoading = false;
                  BlocProvider.of<GetUserdriverDataCubit>(context)
                      .getuserDriverData();
                  CustomSnackBar.displaySuccessMotionToast(
                      state.upDateUserData.message ?? "", context);
                }
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: BlocBuilder<GetUserdriverDataCubit,
                      GetUserdriverDataState>(
                    builder: (context, state) {
                      if (state is GetUserdriverDataSuccess) {
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF242424),
                              textStyle:
                                  appStyle(18, FontWeight.w500, Colors.black),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            onPressed: () async {
                              print(state.getuserDriverData.data?.id ?? 0);
                              await BlocProvider.of<UpDateUserDataCubit>(
                                      context)
                                  .updateUserData(
                                id: state.getuserDriverData.data?.id ?? 0,
                                name: nameController.text,
                                phoneNumber: phoneController.text,
                              );
                              Navigator.of(context).pop();
                            },
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : const Text("Edit"));
                      } else {
                        return const CustomErrorWidget(
                          errMessage: "error",
                        );
                      }
                    },
                  ),
                );
              },
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF242424),
                    textStyle: appStyle(18, FontWeight.w500, Colors.black),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
            )
          ],
        );
      },
    );
  }
}
