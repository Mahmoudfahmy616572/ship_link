import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/constant.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/build_botton.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/services/error_handler.dart';
import 'package:ship_link/core/widgets/text_field.dart';
import 'package:ship_link/driver/presentation/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/core/utils/sizer.dart';

final List<String> _vehicleTypes = ['Bike', 'Motorcycle', 'Car'];

final List<String> _egyptGovernorates = [
  'Alexandria', 'Aswan', 'Asyut', 'Beheira', 'Beni Suef',
  'Cairo', 'Dakahlia', 'Damietta', 'Faiyum', 'Gharbia',
  'Giza', 'Ismailia', 'Kafr El Sheikh', 'Luxor', 'Matruh',
  'Minya', 'Monufia', 'New Valley', 'North Sinai', 'Port Said',
  'Qalyubia', 'Qena', 'Red Sea', 'Sharqia', 'Sohag',
  'South Sinai', 'Suez',
];

class DriverBody extends StatefulWidget {
  const DriverBody({super.key});

  @override
  State<DriverBody> createState() => _DriverBodyState();
}

class _DriverBodyState extends State<DriverBody> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController vehicleNumber = TextEditingController();
  final _selectedVehicleType = ValueNotifier<String?>(null);
  final _selectedState = ValueNotifier<String?>(null);

  final formKey = GlobalKey<FormState>();
  final _isVisiable = ValueNotifier<bool>(false);
  final _isVisiableConfirm = ValueNotifier<bool>(false);

  bool get _needsVehicleNumber => true;

  String _vehicleNumberHint() {
    if (_selectedVehicleType.value == 'Bike') return context.t.tr('bike_type_hint');
    return context.t.tr('vehicle_number');
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    name.dispose();
    phoneNumber.dispose();
    vehicleNumber.dispose();
    _selectedVehicleType.dispose();
    _selectedState.dispose();
    _isVisiable.dispose();
    _isVisiableConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is RegisterDriversuccess) {
          if (token != '') {
            Navigator.of(context).pushNamedAndRemoveUntil(
                MainScreenDriver.routName, (Route<dynamic> route) => false);
            CustomSnackBar.displaySuccessMotionToast(
                context.t.tr('driver_registered_success'), context);
          }
        } else if (state is RegisterDriverfaild) {
          CustomSnackBar.displayErrorMotionToast(
              ErrorHandler.getFriendlyMessage(state.message, context.t.tr), context);
        }
      },
      builder: (context, state) {
        final cubit = AuthCubit.get(context);
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  Container(
                    width: 72.w, height: 72.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        size: 38, color: Colors.white),
                  ),
                  SizedBox(height: 20.h),
                  Text(context.t.tr('create_driver_account'),
                      style: appStyle(
                          24, FontWeight.w700, const Color(0xFF111827))),
                  SizedBox(height: 6.h),
                  Text(context.t.tr('fill_details_to_start'),
                      style: appStyle(
                          14, FontWeight.w400, const Color(0xFF6B7280))),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(context.t.tr('personal_information')),
                  SizedBox(height: 12.h),
                  BuildTextField(
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.t.tr('name_is_required');
                      if (v.length < 3) return context.t.tr('name_min_2_chars');
                      return null;
                    },
                    controller: name,
                    hintText: context.t.tr('full_name'),
                    suffixIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF9CA3AF)),
                    obscureText: false,
                  ),
                  SizedBox(height: 14.h),
                  BuildTextField(
                    validator: (value) {
                      if (value!.isEmpty) { return context.t.tr('email_is_required_2'); }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(value)) { return context.t.tr('invalid_email'); }
                      return null;
                    },
                    controller: email,
                    hintText: context.t.tr('email_address_2'),
                    suffixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFF9CA3AF)),
                    obscureText: false,
                    textInputType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 14.h),
                  BuildTextField(
                    validator: (val) {
                      if (val!.length != 11) return context.t.tr('phone_11_digits');
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: phoneNumber,
                    hintText: context.t.tr('phone_number'),
                    suffixIcon: const Icon(Icons.phone_outlined,
                        color: Color(0xFF9CA3AF)),
                    obscureText: false,
                    textInputType: TextInputType.phone,
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(context.t.tr('vehicle_information')),
                  SizedBox(height: 12.h),
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedVehicleType,
                    builder: (context, selectedVehicleType, _) {
                      return DropdownButtonFormField<String>(
                        value: selectedVehicleType,
                        decoration: _inputDec(context.t.tr('vehicle_type'), Icons.time_to_leave_outlined),
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontSize: 15.sp, color: Color(0xFF111827)),
                        items: _vehicleTypes
                            .map((v) => DropdownMenuItem(
                                value: v,
                                child: Text(v,
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Color(0xFF111827)))))
                            .toList(),
                        onChanged: (v) =>
                            _selectedVehicleType.value = v,
                        validator: (v) =>
                            v == null ? context.t.tr('select_vehicle_type') : null,
                      );
                    },
                  ),
                  if (_needsVehicleNumber) ...[
                    SizedBox(height: 14.h),
                    BuildTextField(
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.t.tr('required_field');
                        return null;
                      },
                      controller: vehicleNumber,
                      hintText: _vehicleNumberHint(),
                      suffixIcon: const Icon(Icons.confirmation_number_outlined,
                          color: Color(0xFF9CA3AF)),
                      obscureText: false,
                    ),
                  ],
                  SizedBox(height: 14.h),
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedState,
                    builder: (context, selectedState, _) {
                      return DropdownButtonFormField<String>(
                        value: selectedState,
                        decoration: _inputDec(context.t.tr('governorate'), Icons.location_on_outlined),
                        dropdownColor: Colors.white,
                        style: TextStyle(
                            fontSize: 15.sp, color: Color(0xFF111827)),
                        items: _egyptGovernorates
                            .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g,
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Color(0xFF111827)))))
                            .toList(),
                        onChanged: (v) => _selectedState.value = v,
                        validator: (v) => v == null ? context.t.tr('select_governorate') : null,
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(context.t.tr('security_section')),
                  SizedBox(height: 12.h),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isVisiable,
                    builder: (context, isVisiable, _) {
                      return BuildTextField(
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t.tr('password_required_2');
                          if (v.length < 6) return context.t.tr('min_6_characters');
                          return null;
                        },
                        controller: password,
                        hintText: context.t.tr('password'),
                        obscureText: !isVisiable,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              _isVisiable.value = !isVisiable,
                          icon: Icon(
                              isVisiable
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF9CA3AF)),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 14.h),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isVisiableConfirm,
                    builder: (context, isVisiableConfirm, _) {
                      return BuildTextField(
                        validator: (val) {
                          if (val == null || val.isEmpty) return context.t.tr('confirm_password');
                          if (val != password.text) return context.t.tr('passwords_do_not_match');
                          return null;
                        },
                        controller: confirmPassword,
                        hintText: context.t.tr('confirm_password'),
                        obscureText: !isVisiableConfirm,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              _isVisiableConfirm.value = !isVisiableConfirm,
                          icon: Icon(
                              isVisiableConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF9CA3AF)),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  BuildButton(
                    text: state is RegisterDriverLoading
                        ? context.t.tr('creating_account')
                        : context.t.tr('create_account'),
                    color: AppColors.primary,
                    textStyle: appStyle(16, FontWeight.w600, Colors.white),
                    ontap: state is RegisterDriverLoading
                        ? null
                        : () {
                            if (!formKey.currentState!.validate()) return;
                            cubit.signUpDriver(
                              email: email.text,
                              password: password.text,
                              phoneNumber: phoneNumber.text,
                              name: name.text,
                              vehicleType: _selectedVehicleType.value ?? '',
                              vehicleNumber: _needsVehicleNumber
                                  ? vehicleNumber.text
                                  : '',
                              state: _selectedState.value ?? '',
                            );
                          },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.t.tr('already_have_account_q'),
                          style: appStyle(
                              14, FontWeight.w400, const Color(0xFF6B7280))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(context.t.tr('sign_in_short'),
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
        );
      },
    );
  }

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: appStyle(14, FontWeight.w600, const Color(0xFF374151))),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }
}
