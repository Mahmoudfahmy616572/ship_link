import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/constant.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/providers.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/build_botton.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/services/error_handler.dart';
import 'package:ship_link/core/widgets/text_field.dart';
import 'package:ship_link/user/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:ship_link/driver/presentation/screens/DriverRegister/driver_register.dart';
import 'package:ship_link/driver/presentation/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/core/utils/sizer.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _isVisable = ValueNotifier<bool>(false);
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _isVisable.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = await CredentialsService().loadEmail();
    final savedPassword = await CredentialsService().loadPassword();
    if (savedEmail != null) {
      email.text = savedEmail;
    }
    if (savedPassword != null) {
      password.text = savedPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignInDriverSuccess) {
          if (token != '') {
            Navigator.of(context).pushNamedAndRemoveUntil(
                MainScreenDriver.routName, (Route<dynamic> routes) => false);
            CustomSnackBar.displaySuccessMotionToast(
                context.t.tr('welcome_back_captain'), context);
          }
        } else if (state is SignInDriverFaild) {
          CustomSnackBar.displayErrorMotionToast(
              ErrorHandler.getFriendlyMessage(state.message, context.t.tr), context);
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
                      _LanguageSelector(),
                      SizedBox(height: 24.h),
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
                      Text(context.t.tr('welcome_back'),
                          style: appStyle(
                              28, FontWeight.w700, const Color(0xFF111827))),
                      SizedBox(height: 8.h),
                      Text(context.t.tr('sign_in_to_start'),
                          style: appStyle(
                              15, FontWeight.w400, const Color(0xFF6B7280))),
                      SizedBox(height: 40.h),
                      BuildTextField(
                        controller: email,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return context.t.tr('email_is_required');
                          if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                              .hasMatch(value)) {
                            return context.t.tr('invalid_email');
                          }
                          return null;
                        },
                        hintText: context.t.tr('email_address'),
                        suffixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF9CA3AF)),
                        obscureText: false,
                        textInputType: TextInputType.emailAddress,
                        maxLength: 254,
                      ),
                      SizedBox(height: 16.h),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isVisable,
                        builder: (context, isVisable, _) {
                          return BuildTextField(
                            controller: password,
                            validator: (value) {
                              if (value == null || value.isEmpty) return context.t.tr('password_is_required');
                              return null;
                            },
                            obscureText: !isVisable,
                            maxLength: 128,
                            hintText: context.t.tr('password_label'),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  _isVisable.value = !isVisable,
                              icon: Icon(
                                  isVisable
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF9CA3AF)),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, ResetPasswordScreen.routName),
                            child: Text(context.t.tr('forgot_password_q'),
                                style: appStyle(
                                    14, FontWeight.w500, AppColors.primary)),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      BuildButton(
                        text: state is SignInDriverLoading
                            ? context.t.tr('signing_in')
                            : context.t.tr('sign_in'),
                        color: AppColors.primary,
                        textStyle:
                            appStyle(16, FontWeight.w600, Colors.white),
                        ontap: state is SignInDriverLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  CredentialsService()
                                      .save(email.text, password: password.text);
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
                            child: Text(context.t.tr('or_continue_with'),
                                style: appStyle(13, FontWeight.w400,
                                    const Color(0xFF9CA3AF))),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      GestureDetector(
                        onTap: () => context.read<AuthCubit>().signInWithGoogleDriver(),
                        child: _socialBtn("assets/icons/googel icon.svg", isGoogle: true),
                      ),
                      SizedBox(height: 32.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.t.tr('dont_have_account_q'),
                              style: appStyle(14, FontWeight.w400,
                                  const Color(0xFF6B7280))),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, DriverRegister.routName),
                            child: Text(context.t.tr('sign_up'),
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

  Widget _LanguageSelector() {
    final locale = context.watch<LocaleProvider>().locale;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _langBtn('EN', const Locale('en'), locale == const Locale('en')),
        SizedBox(width: 12.w),
        _langBtn('AR', const Locale('ar'), locale == const Locale('ar')),
      ],
    );
  }

  Widget _langBtn(String label, Locale target, bool active) {
    return GestureDetector(
      onTap: () => context.read<LocaleProvider>().setLocale(target),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: active ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: appStyle(
            16,
            FontWeight.w600,
            active ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _socialBtn(String asset, {bool isGoogle = false}) {
    return Container(
      width: isGoogle ? 56.w : 52.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: SvgPicture.asset(asset, width: 24, height: 24),
      ),
    );
  }
}