import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/user/presentation/screens/login/login_screen.dart';
import 'package:ship_link/user/presentation/screens/create_account/create_account_screen.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/utils/sizer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static String routName = '/welcome';
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              _buildLogo(),
              SizedBox(height: 40.h),
              Text(
                context.t.tr('welcome_to_shopease'),
                style: GoogleFonts.inter(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: 280.w,
                child: Text(
                  context.t.tr('discover_best_products'),
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 48.h),
              _buildIllustration(),
              SizedBox(height: 48.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, LoginScreen.routName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                  child: Text(context.t.tr('login')),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, CreateAccountScreen.routName),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cta,
                    side: const BorderSide(color: AppColors.cta, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(context.t.tr('create_account')),
                ),
              ),
              SizedBox(height: 32.h),
              _buildSocialSection(context),
              SizedBox(height: 24.h),
              SizedBox(
                width: 280.w,
                child: Text(
                  context.t.tr('by_continuing_agree'),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.cta),
        SizedBox(height: 16.h),
        Text.rich(
          TextSpan(
            text: context.t.tr('shop'),
            style: GoogleFonts.inter(
              fontSize: 36.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
            children: [
              TextSpan(
                text: context.t.tr('ease'),
                style: GoogleFonts.inter(color: AppColors.cta),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 260.w,
      height: 220.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            top: 10,
            child: Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.card_giftcard_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.cta.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: AppColors.cta,
            ),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoadingState && mounted) {
        } else if (state is ErrorState && mounted) {
          CustomSnackBar.error(state.message, context);
        } else if (state is SuccessState && mounted) {
        } else if (state is NewGoogleUser && mounted) {
          Navigator.pushReplacementNamed(
              context, '/createAccount');
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFF6B7280))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    context.t.tr('or_continue_with'),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFF6B7280))),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _socialButton(
                    iconPath: 'assets/icons/googel icon.svg',
                    label: context.t.tr('google'),
                    onTap: () => AuthCubit.get(context).signInWithGoogle(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _socialButton(
                    iconPath: 'assets/icons/apple icon.svg',
                    label: context.t.tr('apple'),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _socialButton({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 20, height: 20),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
