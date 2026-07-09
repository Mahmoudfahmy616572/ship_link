import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';

class OtpWeb extends StatefulWidget {
  final String email;
  const OtpWeb({super.key, required this.email});
  static String routName = '/otp';

  @override
  State<OtpWeb> createState() => _OtpWebState();
}

class _OtpWebState extends State<OtpWeb> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  int _secondsRemaining = 120;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(4, (_) => FocusNode());
    _controllers = List.generate(4, (_) => TextEditingController());
    _startTimer();
  }

  @override
  void dispose() {
    for (final node in _focusNodes) { node.dispose(); }
    for (final ctrl in _controllers) { ctrl.dispose(); }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 120;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) _canResend = true;
      });
      return _secondsRemaining > 0 && mounted;
    });
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (index == 3 && value.length == 1) {
      _focusNodes[3].unfocus();
    }
  }

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 30),
            Icon(Icons.mail_outline, size: 80, color: AppColors.cta),
            SizedBox(height: 24),
            Text(context.t.tr('verification'), style: appStyle(32, FontWeight.w700, const Color(0xFF111827))),
            SizedBox(height: 8),
            Text(context.t.tr('otp_verification'), style: appStyle(16, FontWeight.w400, const Color(0xFF6B7280))),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: '${context.t.tr('enter_otp')} ',
                style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280)),
                children: [TextSpan(text: widget.email, style: appStyle(14, FontWeight.w600, const Color(0xFF111827)))],
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 60, height: 60,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: appStyle(24, FontWeight.w700, const Color(0xFF111827)),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.cta, width: 2),
                        ),
                      ),
                      onChanged: (v) => _onChanged(i, v),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 24),
            Text(
              _canResend
                  ? context.t.tr('resend')
                  : '${(_secondsRemaining ~/ 60)}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
              style: appStyle(14, FontWeight.w500, _canResend ? AppColors.cta : const Color(0xFF9CA3AF)),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _otp.length == 4 ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(context.t.tr('submit'), style: appStyle(16, FontWeight.w600, Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
