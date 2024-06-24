// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';

import '../../../../constant/constant.dart';
import '../../../shared/app_style.dart';
import '../../../shared/snackBar/snack_bar.dart';
import '../../../shared/text_field.dart';
import '../../../user/screens/addShippingAddress/components/build_button.dart';
import '../../../user/screens/signup/register/User/components/link_text.dart';
import '../../../user/screens/signup/register/User/components/space.dart';
import '../../../user/screens/signup/register/User/components/title_text_field.dart';
import '../../../user/screens/signup/register/User/components/top_logo.dart';
import '../MainScreen/main_screen_driver.dart';

List<String> list = <String>['Bike', 'Motorcycle', 'car'];

class DriverBody extends StatefulWidget {
  const DriverBody({super.key});

  @override
  State<DriverBody> createState() => _DriverBodyState();
}

class _DriverBodyState extends State<DriverBody> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController stateId = TextEditingController();
  final TextEditingController gender = TextEditingController();
  String dropdownValue = list.first;
  final formKey = GlobalKey<FormState>();
  bool isVisiable = false;
  bool isVisiableConfirm = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        var cubit = AuthCubit.get(context);
        if (state is RegisterDriversuccess) {
          if (token != '') {
            Navigator.of(context).pushNamedAndRemoveUntil(
                MainScreenDriver.routName, (Route<dynamic> route) => false);
            CustomSnackBar.displaySuccessMotionToast(
                "${cubit.signupDriver.message}", context);
          }
        } else if (state is RegisterDriverfaild) {
          CustomSnackBar.displayErrorMotionToast(
              "${cubit.signupDriver.message}", context);
        }
      },
      builder: (context, state) {
        var cubit = AuthCubit.get(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: TopLogo(
                  text: 'Sign UP Driver',
                )),
                Expanded(
                    child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Space(),
                        const TitleTextField(
                          text: 'Name',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          validator: (currentValue) {
                            var nonNullValue = currentValue ?? '';
                            if (nonNullValue.isEmpty) {
                              return ("first name is required");
                            }
                            if (currentValue!.length < 3) {
                              return 'Name must be more than 2 charater';
                            }

                            return null;
                          },
                          controller: name,
                          hintText: "Enter your name",
                          obscureText: false,
                          textInputType: TextInputType.emailAddress,
                        ),
                        const Space(),
                        const TitleTextField(
                          text: 'Email',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter an email address';
                            } else if (!RegExp(
                                    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null; // Return null if the input is valid
                          },
                          controller: email,
                          hintText: "Enter Your Email",
                          obscureText: false,
                          textInputType: TextInputType.emailAddress,
                        ),
                        const Space(),
                        const TitleTextField(
                          text: 'Phone Number',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          validator: (val) {
                            if (val!.length != 11) {
                              return ('Mobile Number must be of 11 digit');
                            } else {
                              return null;
                            }
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: phoneNumber,
                          hintText: "Enter Your Phone Number",
                          obscureText: false,
                          textInputType: TextInputType.phone,
                        ),
                        const Space(),
                        const TitleTextField(
                          text: 'Address',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          validator: (currentValue) {
                            var nonNullValue = currentValue ?? '';
                            if (nonNullValue.isEmpty) {
                              return ("address is required");
                            }
                            if (currentValue!.length < 10) {
                              return 'address must be more accurate and detailed';
                            }

                            return null;
                          },
                          controller: address,
                          hintText: "Enter Your Address",
                          obscureText: false,
                          textInputType: TextInputType.streetAddress,
                        ),
                        // const Space(),
                        // const TitleTextField(
                        //   text: ' Vehicle Type',
                        // ),
                        // const SizedBox(
                        //   height: 5,
                        // ),
                        // Container(
                        //     padding: const EdgeInsets.only(left: 10, right: 10),
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(9),
                        //         color: Colors.black),
                        //     child: dropDownMethod()),
                        const Space(),
                        const TitleTextField(
                          text: 'postalCode',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          controller: postalCode,
                          hintText: "Enter Your postalCode",
                          obscureText: false,
                          textInputType: TextInputType.text,
                        ),
                        const Space(),
                        const TitleTextField(
                          text: 'Gender',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          controller: gender,
                          hintText: "Enter Your Gender",
                          obscureText: false,
                          textInputType: TextInputType.text,
                        ),
                        const Space(),
                        const TitleTextField(
                          text: 'State id',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          validator: (currentValue) {
                            var nonNullValue = currentValue ?? '';
                            if (nonNullValue.isEmpty) {
                              return ("State id is Required");
                            }
                            return null;
                          },
                          controller: stateId,
                          hintText: "Enter Your State id",
                          textInputType: TextInputType.text,
                          obscureText: false,
                        ),
                        const Space(),
                        const TitleTextField(
                          text: 'Password',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                            validator: (passCurrentValue) {
                              RegExp regex = RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                              var passNonNullValue = passCurrentValue ?? "";
                              if (passNonNullValue.isEmpty) {
                                return ("Password is required");
                              } else if (passNonNullValue.length < 6) {
                                return ("Password Must be more than 5 characters");
                              } else if (!regex.hasMatch(passNonNullValue)) {
                                return ("Password should contain upper,lower,digit and Special character ");
                              }
                              return null;
                            },
                            controller: password,
                            hintText: "Enter Your Password",
                            obscureText: isVisiable ? true : false,
                            textInputType: TextInputType.text,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisiable = !isVisiable;
                                });
                              },
                              icon: isVisiable
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                            )),
                        const Space(),
                        const TitleTextField(
                          text: 'Confirm Password',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                            validator: (val) {
                              if (val!.isEmpty) return ('Empty');
                              if (val != password.text) return ('Not Match');
                              return null;
                            },
                            controller: confirmPassword,
                            hintText: "Enter Your Confirm Password",
                            obscureText: isVisiableConfirm ? true : false,
                            textInputType: TextInputType.text,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisiableConfirm = !isVisiableConfirm;
                                });
                              },
                              icon: isVisiableConfirm
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                            )),
                        const SizedBox(
                          height: 33,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: BuildButton(
                              text: 'Sign up',
                              color: Colors.white,
                              textStyle:
                                  appStyle(17, FontWeight.w700, Colors.black),
                              ontap: () {
                                cubit.signUpDriver(
                                    email: email.text,
                                    password: password.text,
                                    phoneNumber: phoneNumber.text,
                                    address: address.text,
                                    gender: gender.text,
                                    code: postalCode.text,
                                    passwordConfirmation: confirmPassword.text,
                                    name: name.text,
                                    vehicleNumber: "145641654165",
                                    stateId: stateId.text);
                              }),
                        ),
                        const Space(),
                        const LinkText()
                      ],
                    ),
                  ],
                ))
              ],
            ),
          ),
        );
      },
    );
  }

  DropdownButton<String> dropDownMethod() {
    return DropdownButton<String>(
      onTap: () {},
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(color: Colors.black),
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
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
