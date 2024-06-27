import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/text_field.dart';
import 'package:ship_link/views/user/screens/ForgotPassword/forgot_password.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/sign_in/components/signup_row.dart';
import 'package:ship_link/views/user/screens/sign_in/components/top_screen_logo.dart';

import '../../../../../cubits/auth/cubit/auth_cubit.dart';
import '../../../../../cubits/auth/cubit/auth_stat.dart';
import '../../../../shared/button_sign.dart';
import '../../../../shared/snackBar/snack_bar.dart';
import 'divider_row.dart';
import 'media_row.dart';

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
                "${cubit.userSignIn.message}", context);
          }
        } else if (state is SignInFaild) {
          CustomSnackBar.displayErrorMotionToast(
              "Email or Password Incorrect", context);
        }
      },
      builder: (context, state) {
        var cubit = AuthCubit.get(context);

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const TopScreenLogo(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.09,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  width: double.infinity,
                  height: 600,
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
                                  "Welcome Back!",
                                  style: appStyle(
                                    35,
                                    FontWeight.bold,
                                    const Color(0xFFEFEFEF),
                                  ),
                                ),
                                const Text(
                                  "welcome back we missed you",
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 228, 226, 226)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                textfieldLable(text: 'Email'),
                                const SizedBox(
                                  height: 10,
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
                                  hintText: 'Enter your email',
                                  suffixIcon: const Icon(Icons.email),
                                  obscureText: false,
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                textfieldLable(text: 'Password'),
                                const SizedBox(
                                  height: 10,
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
                                  hintText: 'Enter your password',
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
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, ForgotPassword.routName);
                                      },
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                BuildButton(
                                  text: 'Sign In',
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
                          const SizedBox(
                            height: 20,
                          ),
                          const DividerRow(),
                          const SizedBox(
                            height: 30,
                          ),
                          const MediaRow(),
                          const SizedBox(
                            height: 15,
                          ),
                          const SignUpRow(),
                          const SizedBox(
                            height: 15,
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
      padding: const EdgeInsets.only(left: 7),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
