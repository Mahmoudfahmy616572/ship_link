import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/text_field.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/reset_password/reset_password_screen.dart';
import 'package:ship_link/views/user/screens/sign_in/components/signup_row.dart';
import 'package:ship_link/views/user/screens/sign_in/components/top_screen_logo.dart';

import '../../../../../cubits/auth/cubit/auth_cubit.dart';
import '../../../../../cubits/auth/cubit/auth_stat.dart';
import '../../../../shared/button_sign.dart';
import '../../../../shared/snackBar/snack_bar.dart';
import 'divider_row.dart';
import 'media_row.dart';
import 'package:ship_link/utils/sizer.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isVisable = false;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        var cubit = AuthCubit.get(context);
        if (state is SignInSuccess) {
          if (token != '') {
            Navigator.pushReplacementNamed(context, MainScreen.routName);
            CustomSnackBar.displaySuccessMotionToast(
                context.t.tr('welcome_back'), context);
          }
        } else if (state is SignInFaild) {
          CustomSnackBar.displayErrorMotionToast(
              context.t.tr('email_or_password_incorrect'), context);
        }
      },
      builder: (context, state) {
        var cubit = AuthCubit.get(context);

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30.h,
                ),
                const TopScreenLogo(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.09,
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
                  width: double.infinity,
                  height: 600.h,
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
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  context.t.tr('welcome_back_title'),
                                  style: appStyle(
                                    35,
                                    FontWeight.bold,
                                    const Color(0xFFEFEFEF),
                                  ),
                                ),
                                Text(
                                  context.t.tr('welcome_back_subtitle'),
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 228, 226, 226)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                textfieldLable(text: context.t.tr('email')),
                                SizedBox(
                                  height: 10.h,
                                ),
                                BuildTextField(
                                  controller: email,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "* Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  hintText: context.t.tr('enter_email'),
                                  suffixIcon: const Icon(Icons.email),
                                  obscureText: false,
                                ),
                                SizedBox(
                                  height: 25.h,
                                ),
                                textfieldLable(text: context.t.tr('password')),
                                SizedBox(
                                  height: 10.h,
                                ),
                                BuildTextField(
                                  controller: password,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "* Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  obscureText: isVisable ? true : false,
                                  hintText: context.t.tr('enter_password'),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isVisable = !isVisable;
                                        });
                                      },
                                      icon: isVisable
                                          ? const Icon(Icons.visibility)
                                          : const Icon(Icons.visibility_off)),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            ResetPasswordScreen.routName);
                                      },
                                      child: Text(
                                        context.t.tr('forgot_password'),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 25.h,
                                ),
                                BuildButton(
                                  text: context.t.tr('sign_in'),
                                  color: Colors.white,
                                  ontap: () {
                                    cubit.signIN(
                                        email: email.text,
                                        password: password.text);
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          DividerRow(),
                          SizedBox(
                            height: 30.h,
                          ),
                          const MediaRow(),
                          SizedBox(
                            height: 15.h,
                          ),
                          SignUpRow(),
                          SizedBox(
                            height: 15.h,
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Padding textfieldLable({required String text}) {
    return Padding(
      padding: EdgeInsets.only(left: 7.w),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
