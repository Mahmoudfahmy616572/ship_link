// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:ship_link/views/driver/screens/DriverHome/driver_home.dart';

import '../../../shared/app_style.dart';
import '../../../shared/text_field.dart';
import '../../../user/screens/addShippingAddress/components/build_button.dart';
import '../../../user/screens/signup/register/User/components/link_text.dart';
import '../../../user/screens/signup/register/User/components/space.dart';
import '../../../user/screens/signup/register/User/components/title_text_field.dart';
import '../../../user/screens/signup/register/User/components/top_logo.dart';

List<String> list = <String>['Bike', 'Motorcycle', 'car'];

class DriverBody extends StatefulWidget {
  const DriverBody({super.key});

  @override
  State<DriverBody> createState() => _DriverBodyState();
}

class _DriverBodyState extends State<DriverBody> {
  String dropdownValue = list.first;

  bool isVisiable = false;
  bool isVisiableConfirm = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                  // const NameTextField(),
                  const Space(),
                  const TitleTextField(
                    text: 'Email',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const BuildTextField(
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
                  const BuildTextField(
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
                  const BuildTextField(
                    hintText: "Enter Your Address",
                    obscureText: false,
                    textInputType: TextInputType.streetAddress,
                  ),
                  const Space(),
                  const TitleTextField(
                    text: ' Vehicle Type',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          color: Colors.black),
                      child: dropDownMethod()),
                  const Space(),
                  const TitleTextField(
                    text: 'Password',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  BuildTextField(
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
                      textStyle: appStyle(17, FontWeight.w700, Colors.black),
                      ontap: () {
                        Navigator.pushNamed(context, DriverHome.routName);
                      },
                    ),
                  ),
                  const Space(),
                  const LinkText()
                ],
              ),
            ],
          ))
        ],
      ),
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
