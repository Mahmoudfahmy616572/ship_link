import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/otp/otp_screen.dart';
import 'package:ship_link/views/shared/app_style.dart';

import '../../../shared/button_sign.dart';
import '../../../shared/text_field.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Image.asset("assets/images/Forgot password.png"),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.57,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage("assets/images/background_image.jpg"),
                          colorFilter: ColorFilter.mode(
                              Colors.black, BlendMode.softLight),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Forgot Password!",
                                style: appStyle(
                                  35,
                                  FontWeight.bold,
                                  const Color(0xFFEFEFEF),
                                ),
                              ),
                              const Text(
                                "Don’t worry ! It happens. Please enter the phone\n number we will send the OTP in this phone number.",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 228, 226, 226)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BuildTextField(
                              obscureText: false,
                              hintText: 'Enter the phone number',
                              suffixIcon: Icon(Icons.email),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, OtpScreen.routName);
                              },
                              child: const BuildButton(
                                text: 'Continue',
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
