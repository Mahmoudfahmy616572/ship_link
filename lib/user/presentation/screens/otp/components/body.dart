import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _BodyState extends State<Body> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _remaining = 0;
  bool _submitting = false;

  // Animations
  late AnimationController _iconController;
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;

  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  late AnimationController _otpController;
  late Animation<double> _otpFadeIn;

  late AnimationController _btnController;
  late Animation<double> _btnPulse;

  late AnimationController _particleController;

  // Per-field scale animations
  late final List<AnimationController> _fieldControllers = List.generate(
    6,
    (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    ),
  );
  late List<Animation<double>> _fieldScales;

  // Shake animation on error
  late AnimationController _shakeController;
  late Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();

    // Icon bounce + rotate
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconRotation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutBack),
    );

    // Fade in + slide up for text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    // OTP fields stagger
    _otpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _otpFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _otpController, curve: Curves.easeOut),
    );

    // Button pulse
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _btnPulse = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );

    // Particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Field scales
    _fieldScales = List.generate(
      6,
      (i) => Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _fieldControllers[i], curve: Curves.easeOut),
      ),
    );

    // Shake
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeOffset = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Staggered entrance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _iconController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _otpController.forward();
    });

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _iconController.dispose();
    _fadeController.dispose();
    _otpController.dispose();
    _btnController.dispose();
    _particleController.dispose();
    _shakeController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final fc in _fieldControllers) {
      fc.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remaining = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) t.cancel();
      });
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _fieldControllers[index].forward().then((_) {
        _fieldControllers[index].reverse();
      });
      HapticFeedback.lightImpact();
    }
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    if (_otpCode.length == 6 && !_submitting) {
      _submit();
    }
  }

  void _submit() {
    final code = _otpCode;
    if (code.length < 6) {
      _shakeFields();
      CustomSnackBar.info('Please enter all 6 digits', context);
      return;
    }
    setState(() => _submitting = true);
    AuthCubit.get(context).verifyRegistrationOtp(code);
  }

  void _shakeFields() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);
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
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is OtpVerifySuccess && mounted) {
            // OTP verified — now complete the Supabase registration
            AuthCubit.get(context).completeSignUpAfterOtp();
          } else if (state is Registersuccess && mounted) {
            setState(() => _submitting = false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LocationPicker()),
              (route) => false,
            );
          } else if (state is OtpVerifyFaild && mounted) {
            setState(() => _submitting = false);
            _shakeFields();
            CustomSnackBar.error(state.message, context);
            for (final c in _controllers) {
              c.clear();
            }
            _focusNodes[0].requestFocus();
          } else if (state is OtpSendSuccess && mounted) {
            CustomSnackBar.success('Code resent successfully', context);
          } else if (state is OtpSendFaild && mounted) {
            CustomSnackBar.error(state.message, context);
          } else if (state is Registerfaild && mounted) {
            setState(() => _submitting = false);
            CustomSnackBar.error(state.message, context);
          }
        },
        child: Stack(
          children: [
            // Animated gradient background
            _buildBackground(),
            // Floating particles
            _buildParticles(),
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w, top: 8.h),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          _buildAnimatedIcon(),
                          SizedBox(height: 28.h),
                          _buildTextSection(),
                          SizedBox(height: 40.h),
                          _buildOtpFields(),
                          SizedBox(height: 36.h),
                          _buildSubmitButton(),
                          SizedBox(height: 24.h),
                          _buildTimerSection(),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cta.withValues(alpha: 0.95),
                AppColors.cta.withValues(alpha: 0.7),
                const Color(0xFF1a1a2e),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        final t = _particleController.value;
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          painter: _ParticlePainter(t),
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScale.value,
          child: Transform.rotate(
            angle: _iconRotation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Column(
          children: [
            Text(
              context.t.tr('verification'),
              style: GoogleFonts.inter(
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              context.t.tr('otp_verification'),
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text.rich(
                TextSpan(
                  text: '${context.t.tr('enter_otp')} ',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return AnimatedBuilder(
      animation: _otpController,
      builder: (context, _) {
        return Opacity(
          opacity: _otpFadeIn.value,
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final shake =
                  sin(_shakeController.value * pi * 4) * 8 * (1 - _shakeController.value);
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return _buildOtpField(i);
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpField(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;
    final isFocused = _focusNodes[index].hasFocus;

    return AnimatedBuilder(
      animation: _fieldControllers[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _fieldScales[index].value,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 50.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: hasValue
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasValue
                ? Colors.white
                : isFocused
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
            width: hasValue ? 2.0 : 1.5,
          ),
          boxShadow: hasValue
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.inter(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (v) => _onChanged(v, index),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _btnController,
      builder: (context, child) {
        return Transform.scale(
          scale: _submitting ? 1.0 : _btnPulse.value,
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 58.h,
        child: ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.cta,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
            disabledForegroundColor: AppColors.cta.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.25),
          ),
          child: _submitting
              ? SizedBox(
                  width: 26.w,
                  height: 26.h,
                  child: CircularProgressIndicator(
                    color: AppColors.cta,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(context.t.tr('submit')),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _remaining > 0
          ? Row(
              key: const ValueKey('timer'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    size: 18, color: Colors.white.withValues(alpha: 0.7)),
                SizedBox(width: 6.w),
                Text(
                  _timerText,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  context.t.tr('resend_code_in'),
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            )
          : GestureDetector(
              key: const ValueKey('resend'),
              onTap: _resend,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 18, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      context.t.tr('resend'),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Floating Particles ───

class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rng = Random(42);

    for (int i = 0; i < 20; i++) {
      final speed = 0.2 + rng.nextDouble() * 0.5;
      final x = (rng.nextDouble() * size.width);
      final y =
          ((t * speed * size.height + rng.nextDouble() * size.height) %
                  size.height);
      final radius = 1.5 + rng.nextDouble() * 3.0;
      final opacity = 0.08 + rng.nextDouble() * 0.12;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}
