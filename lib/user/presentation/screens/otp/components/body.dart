import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/screens/location_picker/location_picker.dart';
import 'package:ship_link/core/utils/sizer.dart';

class Body extends StatefulWidget {
  const Body({super.key, required this.email});
  final String email;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _remaining = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remaining = 300; // 5 minutes
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          t.cancel();
        }
      });
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all 6 digits entered
    if (_otpCode.length == 6 && !_submitting) {
      _submit();
    }
  }

  void _submit() {
    final code = _otpCode;
    if (code.length < 6) {
      CustomSnackBar.info('Please enter all 6 digits', context);
      return;
    }
    setState(() => _submitting = true);
    AuthCubit.get(context).verifyRegistrationOtp(code);
  }

  void _resend() {
    AuthCubit.get(context).resendRegistrationOtp();
    _startTimer();
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  String get _timerText {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is OtpVerifySuccess && mounted) {
            setState(() => _submitting = false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LocationPicker()),
              (route) => false,
            );
          } else if (state is OtpVerifyFaild && mounted) {
            setState(() => _submitting = false);
            CustomSnackBar.error(state.message, context);
            for (final c in _controllers) {
              c.clear();
            }
            _focusNodes[0].requestFocus();
          } else if (state is OtpSendSuccess && mounted) {
            CustomSnackBar.success('Code resent successfully', context);
          } else if (state is OtpSendFaild && mounted) {
            CustomSnackBar.error(state.message, context);
          } else if (state is Registersuccess && mounted) {
            setState(() => _submitting = false);
          } else if (state is Registerfaild && mounted) {
            setState(() => _submitting = false);
            CustomSnackBar.error(state.message, context);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                // Icon
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.cta.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mark_email_read_outlined,
                      size: 40, color: AppColors.cta),
                ),
                SizedBox(height: 24.h),
                Text(
                  context.t.tr('verification'),
                  style: GoogleFonts.inter(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.t.tr('otp_verification'),
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text.rich(
                  TextSpan(
                    text: '${context.t.tr('enter_otp')} ',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                // OTP Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 48.w,
                      height: 56.h,
                      child: TextFormField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB), width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                                color: AppColors.cta, width: 1.5),
                          ),
                        ),
                        onChanged: (v) => _onChanged(v, i),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 32.h),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(context.t.tr('submit')),
                  ),
                ),
                SizedBox(height: 24.h),
                // Timer + Resend
                if (_remaining > 0)
                  Text(
                    '${context.t.tr('resend_code_in')} $_timerText',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _resend,
                    child: Text(
                      context.t.tr('resend'),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cta,
                      ),
                    ),
                  ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
