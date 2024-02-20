import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/views/screens/MainScreen/main_screen.dart';

import '../../../../routs.dart';
import '../../../shared/app_style.dart';
import '../../../shared/button_sign.dart';
import 'expired_time.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late FocusNode pin2focusNode;
  late FocusNode pin3focusNode;
  late FocusNode pin4focusNode;
  @override
  void initState() {
    super.initState();
    pin2focusNode = FocusNode();
    pin3focusNode = FocusNode();
    pin4focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2focusNode.dispose();
    pin3focusNode.dispose();
    pin4focusNode.dispose();
  }

  void nextField({required String value, required FocusNode focusNode}) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
          child: TextButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            content: SizedBox(
              width: 380,
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(children: [
                    SizedBox(
                        width: 125,
                        height: 170,
                        child: Image.asset("assets/images/iphone.png")),
                    Positioned(
                      right: -1,
                      top: 50,
                      child: SvgPicture.asset("assets/icons/checkIcon.svg"),
                    ),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Password Update \nSuccessfullys',
                    style: appStyle(30, FontWeight.bold, Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'your password has been \n updated successfuly',
                    style: appStyle(17, FontWeight.normal, Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(9)),
                    child: Center(
                      child: Text(
                        "Back to home",
                        style: appStyle(20, FontWeight.w600, Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Image.asset("assets/images/otp_logo.png"),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.67,
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
                                "Verification",
                                style: appStyle(
                                  35,
                                  FontWeight.bold,
                                  const Color(0xFFEFEFEF),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Text(
                                "OTP VERIFICATION",
                                style: appStyle(
                                  18,
                                  FontWeight.w500,
                                  const Color(0xFFEFEFEF),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text.rich(
                                TextSpan(
                                    text: "Enter the OTP sent to ",
                                    style: const TextStyle(color: Colors.white),
                                    children: [
                                      TextSpan(
                                        text: '- +201897650001',
                                        style: appStyle(
                                            14, FontWeight.w600, Colors.black),
                                      )
                                    ]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: otpForm(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        expiredTime(),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t receive code ? ",
                              style:
                                  appStyle(15, FontWeight.w400, Colors.white),
                            ),
                            Text("Re-send",
                                style:
                                    appStyle(15, FontWeight.w600, Colors.white))
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          // onTap: () {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => const PopUpMsg()));
                          // },
                          child: const BuildButton(
                            text: 'Submit',
                            color: Colors.white,
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Row otpForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 60,
          child: TextFormField(
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
            decoration: otpInputDecoration,
            onChanged: (value) {
              nextField(value: value, focusNode: pin2focusNode);
            },
          ),
        ),
        SizedBox(
          width: 60,
          child: TextFormField(
            focusNode: pin2focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
            decoration: otpInputDecoration,
            onChanged: (value) {
              nextField(value: value, focusNode: pin3focusNode);
            },
          ),
        ),
        SizedBox(
          width: 60,
          child: TextFormField(
            focusNode: pin3focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
            decoration: otpInputDecoration,
            onChanged: (value) {
              nextField(value: value, focusNode: pin4focusNode);
            },
          ),
        ),
        SizedBox(
          width: 60,
          child: TextFormField(
            focusNode: pin4focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
            decoration: otpInputDecoration,
            onChanged: (value) {
              pin4focusNode.unfocus();
            },
          ),
        ),
      ],
    );
  }
}
