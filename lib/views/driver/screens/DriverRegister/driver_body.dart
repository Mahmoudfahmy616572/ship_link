import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/build_botton.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/shared/text_field.dart';
import 'package:ship_link/views/driver/screens/MainScreen/main_screen_driver.dart';
import 'package:ship_link/utils/sizer.dart';

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
  String? selectedVehicleType;
  String? selectedState;

  final formKey = GlobalKey<FormState>();
  bool isVisiable = false;
  bool isVisiableConfirm = false;

  bool get _needsVehicleNumber => true;

  String _vehicleNumberHint() {
    if (selectedVehicleType == 'Bike') return 'Bike type (e.g. Mountain, Electric)';
    return 'Vehicle number';
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
                "Driver registered successfully", context);
          }
        } else if (state is RegisterDriverfaild) {
          CustomSnackBar.displayErrorMotionToast(
              "Something went wrong. Please try again later.", context);
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
                  Text("Create Driver Account",
                      style: appStyle(
                          24, FontWeight.w700, const Color(0xFF111827))),
                  SizedBox(height: 6.h),
                  Text("Fill in your details to get started",
                      style: appStyle(
                          14, FontWeight.w400, const Color(0xFF6B7280))),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Personal Information'),
                  SizedBox(height: 12.h),
                  BuildTextField(
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Name is required";
                      if (v.length < 3) return 'Name must be more than 2 characters';
                      return null;
                    },
                    controller: name,
                    hintText: "Full name",
                    suffixIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF9CA3AF)),
                    obscureText: false,
                  ),
                  SizedBox(height: 14.h),
                  BuildTextField(
                    validator: (value) {
                      if (value!.isEmpty) { return 'Email is required'; }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(value)) { return 'Invalid email'; }
                      return null;
                    },
                    controller: email,
                    hintText: "Email address",
                    suffixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFF9CA3AF)),
                    obscureText: false,
                    textInputType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 14.h),
                  BuildTextField(
                    validator: (val) {
                      if (val!.length != 11) return 'Phone must be 11 digits';
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: phoneNumber,
                    hintText: "Phone number",
                    suffixIcon: const Icon(Icons.phone_outlined,
                        color: Color(0xFF9CA3AF)),
                    obscureText: false,
                    textInputType: TextInputType.phone,
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Vehicle Information'),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    initialValue: selectedVehicleType,
                    decoration: _inputDec("Vehicle type", Icons.time_to_leave_outlined),
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
                        setState(() => selectedVehicleType = v),
                    validator: (v) =>
                        v == null ? 'Select vehicle type' : null,
                  ),
                  if (_needsVehicleNumber) ...[
                    SizedBox(height: 14.h),
                    BuildTextField(
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedState,
                    decoration: _inputDec("Governorate", Icons.location_on_outlined),
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
                    onChanged: (v) => setState(() => selectedState = v),
                    validator: (v) => v == null ? 'Select governorate' : null,
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Security'),
                  SizedBox(height: 12.h),
                  BuildTextField(
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password required";
                      if (v.length < 6) return "Min 6 characters";
                      return null;
                    },
                    controller: password,
                    hintText: "Password",
                    obscureText: !isVisiable,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => isVisiable = !isVisiable),
                      icon: Icon(
                          isVisiable
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF9CA3AF)),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  BuildTextField(
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Confirm password';
                      if (val != password.text) return 'Passwords do not match';
                      return null;
                    },
                    controller: confirmPassword,
                    hintText: "Confirm password",
                    obscureText: !isVisiableConfirm,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                          () => isVisiableConfirm = !isVisiableConfirm),
                      icon: Icon(
                          isVisiableConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF9CA3AF)),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  BuildButton(
                    text: state is RegisterDriverLoading
                        ? 'Creating account...'
                        : 'Create Account',
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
                              vehicleType: selectedVehicleType ?? '',
                              vehicleNumber: _needsVehicleNumber
                                  ? vehicleNumber.text
                                  : '',
                              state: selectedState ?? '',
                            );
                          },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ",
                          style: appStyle(
                              14, FontWeight.w400, const Color(0xFF6B7280))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text("Sign In",
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