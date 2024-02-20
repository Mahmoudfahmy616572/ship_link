import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ship_link/views/screens/MainScreen/main_screen.dart';

import '../../../../../shared/app_style.dart';
import '../../../../../shared/text_field.dart';
import '../../../../addShippingAddress/components/build_button.dart';
import 'link_text.dart';
import 'space.dart';
import 'title_text_field.dart';
import 'top_logo.dart';

class UserBody extends StatefulWidget {
  const UserBody({super.key});

  @override
  State<UserBody> createState() => _UserBodyState();
}

class _UserBodyState extends State<UserBody> {
  bool isVisiable = false;
  bool isVisiableConfirm = false;
  final formKey = GlobalKey<FormState>();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              text: 'Sign UP User ',
            )),
            Expanded(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Space(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "First Name",
                                style: appStyle(14, FontWeight.normal,
                                    const Color(0xFF6C6C6C)),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: BuildTextField(
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
                                  controller: firstName,
                                  hintText: "Enter Your First Name",
                                  obscureText: false,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Last Name",
                                style: appStyle(14, FontWeight.normal,
                                    const Color(0xFF6C6C6C)),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  child: BuildTextField(
                                    validator: (currentValue) {
                                      var nonNullValue = currentValue ?? '';
                                      if (nonNullValue.isEmpty) {
                                        return ("last name is required");
                                      }
                                      if (currentValue!.length < 3) {
                                        return 'Name must be more than 2 charater';
                                      }

                                      return null;
                                    },
                                    controller: lastName,
                                    hintText: "Enter Your Last Name",
                                    obscureText: false,
                                  )),
                            ],
                          ),
                        ],
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
                      const Space(),
                      const TitleTextField(
                        text: ' Postal Code',
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      BuildTextField(
                        // validator: (postcode) {
                        //   RegExp regExp = RegExp(
                        //       r'^([A-Z]{1,2}\d{1,2}[A-Z]?)\s*(\d[A-Z]{2})$');
                        //   var pureString = postcode!.replaceAll(' ', '');
                        //   var fromat = regExp.hasMatch(pureString);
                        //   if (fromat) {
                        //     final match =
                        //         regExp.firstMatch(pureString.toUpperCase());
                        //     return "${match?.group(1)?.padLeft(2, '0')} ${match?.group(2)?.padLeft(2, '0')}";
                        //   } else {
                        //     return postcode;
                        //   }
                        // },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: postalCode,
                        hintText: "Enter Your Postal Code",
                        obscureText: false,
                        textInputType: TextInputType.number,
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
                            if (formKey.currentState!.validate()) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainScreen()));
                            }
                          },
                        ),
                      ),
                      const Space(),
                      const LinkText(),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
