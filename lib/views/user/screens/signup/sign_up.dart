import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/button_sign.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/driver/screens/DriverRegister/driver.dart';
import 'package:ship_link/views/user/screens/signup/register/Provider/provider.dart';
import 'package:ship_link/views/user/screens/signup/register/User/user.dart';

List<String> list = <String>['User', 'Driver'];

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  static String routName = '/signUp';
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/background_image.jpg"),
                      fit: BoxFit.cover)),
              child: Column(children: [
                const SizedBox(
                  height: 40,
                ),
                Image.asset("assets/images/signin Logo.png"),
                Text(
                  "Sign UP",
                  style: appStyle(25, FontWeight.bold, Colors.black),
                ),
                Text(
                  "Enter your credentials to access your\n account",
                  textAlign: TextAlign.center,
                  style:
                      appStyle(13, FontWeight.normal, const Color(0xFF6C6C6C)),
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SignUp as:",
                        style: appStyle(
                            16, FontWeight.w500, const Color(0xFF6C6C6C)),
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
                          child: dropDownBuilder()),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 120, right: 120),
                  child: BuildButton(
                    text: 'CONTINUE',
                    color: Colors.white,
                    ontap: () {
                      Navigator.pushNamed(context, MainScreen.routName);
                    },
                  ),
                ),
              ])),
        ),
      ),
    );
  }

  DropdownButton<String> dropDownBuilder() {
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
        switch (value) {
          case "User":
            GoRouter.of(context).pushReplacement("/UserRegister");
            break;
          case "Driver":
            GoRouter.of(context).pushReplacement("/DriverRegister");
            break;

        }
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
