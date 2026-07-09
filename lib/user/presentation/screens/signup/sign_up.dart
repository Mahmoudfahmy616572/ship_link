import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/driver/presentation/screens/DriverRegister/driver_register.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/user/presentation/widgets/button_sign.dart';
import 'package:ship_link/user/presentation/screens/MainScreen/main_screen.dart';
import 'package:ship_link/user/presentation/screens/signup/register/User/user.dart';

List<String> list = <String>['User', 'Driver'];

class SignUp extends StatelessWidget {
  const SignUp({super.key});
  static String routName = '/signUp';

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
                      image: AssetImage("assets/images/background_image.webp"),
                      fit: BoxFit.cover)),
              child: Column(children: [
                const SizedBox(
                  height: 40,
                ),
                Image.asset("assets/images/signin Logo.png"),
                Text(
                  context.t.tr('sign_up'),
                  style: appStyle(25, FontWeight.bold, Colors.black),
                ),
                Text(
                  context.t.tr('login_subtitle'),
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
                        context.t.tr('sign_up_as'),
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
                          child: _dropDownBuilder(context)),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 120, right: 120),
                  child: BuildButton(
                    text: context.t.tr('continue_btn'),
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

  DropdownButton<String> _dropDownBuilder(BuildContext context) {
    return DropdownButton<String>(
      onTap: () {},
      value: list.first,
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
        switch (value) {
          case "User":
            Navigator.pushNamed(context, UserRegister.routName);
            break;
          case "Driver":
            Navigator.pushNamed(context, DriverRegister.routName);
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
