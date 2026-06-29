import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/build_elevation_button.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/tracking/driver_tracking_screen.dart';
import 'package:ship_link/utils/sizer.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
    this.userEmail,
  });

  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final confirmState = context.watch<ConfirmCartCubit>().state;
    final orderId = confirmState is ConfirmCartSuccess
        ? confirmState.confirmCart.order?.id
        : null;

    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
        ),
        Center(
          child: Text(
            context.t.tr('success'),
            textAlign: TextAlign.center,
            style: TextStyle(
                letterSpacing: 3,
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Lottie.asset(
          "assets/json/deleivery.json",
          fit: BoxFit.fill,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Text.rich(
          TextSpan(
              style: appStyle(16, FontWeight.normal, AppColors.textPrimary),
              children: [
                TextSpan(text: context.t.tr('order_will_be_delivered')),
                TextSpan(text: context.t.tr('thank_you'))
              ]),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Order code sent to ${userEmail ?? 'your email'}",
                  style: appStyle(13, FontWeight.w500, AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
        ),
        CheckoutButton(
          text: context.t.tr('track_your_orders'),
          ontap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DriverTrackingScreen(
                        orderId: orderId?.toString() ?? "")));
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        CheckoutButton(
          text: context.t.tr('back_to_home'),
          ontap: () {
            Navigator.pushReplacementNamed(context, MainScreen.routName);
          },
        )
      ]),
    );
  }
}
