import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';

import '../../../../../routs.dart';
import '../../../../shared/app_style.dart';
import '../../../../shared/button_sign.dart';
import 'expired_time.dart';
import 'package:ship_link/utils/sizer.dart';

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
              width: 380.w,
              height: 400.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(children: [
                    SizedBox(
                        width: 125.w,
                        height: 170.h,
                        child: Image.asset("assets/images/iphone.png")),
                    Positioned(
                      right: -1,
                      top: 50,
                      child: SvgPicture.asset("assets/icons/checkIcon.svg"),
                    ),
                  ]),
                  SizedBox(
                    height: 15.h,
                  ),
                  Text(
                    context.t.tr('password_update_success'),
                    style: appStyle(30, FontWeight.bold, Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Text(
                    context.t.tr('password_updated_message'),
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
                    height: 40.h,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(9)),
                    child: Center(
                      child: Text(
                        context.t.tr('back_to_home'),
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
            SizedBox(
              height: 30.h,
            ),
            Image.asset("assets/images/otp_logo.png"),
            Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.67,
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
                                context.t.tr('verification'),
                                style: appStyle(
                                  35,
                                  FontWeight.bold,
                                  const Color(0xFFEFEFEF),
                                ),
                              ),
                              SizedBox(
height: 40.h,
                              ),
                              Text(
                                context.t.tr('otp_verification'),
                                style: appStyle(
                                  18,
                                  FontWeight.w500,
                                  const Color(0xFFEFEFEF),
                                ),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Text.rich(
                                TextSpan(
                                    text: context.t.tr('enter_otp'),
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
                        SizedBox(
                          height: 25.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.w),
                          child: otpForm(),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        expiredTime(context),
                        SizedBox(
                          height: 15.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.t.tr('dont_receive_code'),
                              style:
                                  appStyle(15, FontWeight.w400, Colors.white),
                            ),
                            Text(context.t.tr('resend'),
                                style:
                                    appStyle(15, FontWeight.w600, Colors.white))
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        GestureDetector(
                          // onTap: () {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => const PopUpMsg()));
                          // },
                          child: BuildButton(
                            text: context.t.tr('submit'),
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
          width: 60.w,
          child: TextFormField(
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: TextStyle(fontSize: 20.sp),
            textAlign: TextAlign.center,
            decoration: otpInputDecoration,
            onChanged: (value) {
              nextField(value: value, focusNode: pin2focusNode);
            },
          ),
        ),
        SizedBox(
          width: 60.w,
          child: TextFormField(
            focusNode: pin2focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: TextStyle(fontSize: 20.sp),
            textAlign: TextAlign.center,
            decoration: otpInputDecoration,
            onChanged: (value) {
              nextField(value: value, focusNode: pin3focusNode);
            },
          ),
        ),
        SizedBox(
          width: 60.w,
          child: TextFormField(
            focusNode: pin3focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: TextStyle(fontSize: 20.sp),
            textAlign: TextAlign.center,
            decoration: otpInputDecoration,
            onChanged: (value) {
              nextField(value: value, focusNode: pin4focusNode);
            },
          ),
        ),
        SizedBox(
          width: 60.w,
          child: TextFormField(
            focusNode: pin4focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: TextStyle(fontSize: 20.sp),
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
