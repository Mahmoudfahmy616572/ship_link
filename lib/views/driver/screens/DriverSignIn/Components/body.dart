import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/services/cache_service.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/build_botton.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/shared/text_field.dart';
import 'package:ship_link/views/user/screens/reset_password/reset_password_screen.dart';
import 'package:ship_link/views/driver/screens/DriverRegister/driver_register.dart';
import 'package:ship_link/views/driver/screens/MainScreen/main_screen_driver.dart';
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
      listener: (context, state) {
        if (state is SignInDriverSuccess) {
          if (token != '') {
            Navigator.of(context).pushNamedAndRemoveUntil(
                MainScreenDriver.routName, (Route<dynamic> routes) => false);
            CustomSnackBar.displaySuccessMotionToast(
                "Welcome back, Captain!", context);
          }
        } else if (state is SignInDriverFaild) {
          CustomSnackBar.displayErrorMotionToast(
              "Email or Password Incorrect", context);
        }
      },
      builder: (context, state) {
        final cubit = AuthCubit.get(context);
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      Container(
                        width: 80.w, height: 80.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: const Icon(Icons.delivery_dining_rounded,
                            size: 44, color: Colors.white),
                      ),
                      SizedBox(height: 24.h),
                      Text("Welcome Back!",
                          style: appStyle(
                              28, FontWeight.w700, const Color(0xFF111827))),
                      SizedBox(height: 8.h),
                      Text("Sign in to start delivering",
                          style: appStyle(
                              15, FontWeight.w400, const Color(0xFF6B7280))),
                      SizedBox(height: 40.h),
                      BuildTextField(
                        controller: email,
                        validator: (value) {
                          if (value!.isEmpty) return "Email is required";
                          return null;
                        },
                        hintText: 'Email address',
                        suffixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF9CA3AF)),
                        obscureText: false,
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.h),
                      BuildTextField(
                        controller: password,
                        validator: (value) {
                          if (value!.isEmpty) return "Password is required";
                          return null;
                        },
                        obscureText: !isVisable,
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => isVisable = !isVisable),
                          icon: Icon(
                              isVisable
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF9CA3AF)),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, ResetPasswordScreen.routName),
                            child: Text("Forgot Password?",
                                style: appStyle(
                                    14, FontWeight.w500, AppColors.primary)),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      BuildButton(
                        text: state is SignInDriverLoading
                            ? 'Signing in...'
                            : 'Sign In',
                        color: AppColors.primary,
                        textStyle:
                            appStyle(16, FontWeight.w600, Colors.white),
                        ontap: state is SignInDriverLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  CredentialsService()
                                      .save(email.text);
                                  cubit.signINDriver(
                                      email: email.text,
                                      password: password.text);
                                }
                              },
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text("or continue with",
                                style: appStyle(13, FontWeight.w400,
                                    const Color(0xFF9CA3AF))),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialBtn("assets/icons/googel icon.svg"),
                          SizedBox(width: 16.w),
                          _socialBtn("assets/icons/apple icon.svg"),
                          SizedBox(width: 16.w),
                          _socialBtn("assets/icons/facebook icon.svg"),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: appStyle(14, FontWeight.w400,
                                  const Color(0xFF6B7280))),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, DriverRegister.routName),
                            child: Text("Sign Up",
                                style: appStyle(
                                    14, FontWeight.w600, AppColors.primary)),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _socialBtn(String asset) {
    return Container(
      width: 52.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
          child: SvgPicture.asset(asset,
              width: 24, height: 24)),
    );
  }
}