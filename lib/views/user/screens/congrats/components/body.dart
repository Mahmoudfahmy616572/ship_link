import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/mapWebViewScreen/map_web_view_screen.dart';

import '../../../../shared/app_style.dart';
import '../../../../shared/build_elevation_button.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
        ),
        const Center(
          child: Text(
            "SUCCESS!",
            textAlign: TextAlign.center,
            style: TextStyle(
                letterSpacing: 3,
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black),
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
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Text.rich(
          TextSpan(
              style: appStyle(16, FontWeight.normal, Colors.black),
              children: const [
                TextSpan(text: "Your order will be delivered soon.\n"),
                TextSpan(text: "Thank you for choosing our app!")
              ]),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your Order Code:",
              style: appStyle(17, FontWeight.normal, Colors.blue),
            ),
            BlocBuilder<ConfirmCartCubit, ConfirmCartState>(
              builder: (context, state) {
                if (state is ConfirmCartSuccess) {
                  return Text(state.confirmCart.order?.orderCode ?? "Unknown",
                      style: appStyle(17, FontWeight.w600, Colors.red));
                } else if (state is ConfirmCartLoading) {
                  return const CircularProgressIndicator();
                } else if (state is ConfirmCartFailure) {
                  return Text(state.errMessage);
                } else {
                  return const Text("Unknown Error,Please try again later ");
                }
              },
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        CheckoutButton(
          text: "Track your orders",
          ontap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MapWebViewScreen(
                          url: "https://shiplink.spider-te8S.com/search",
                        )));
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        CheckoutButton(
          text: "Back To Home",
          ontap: () {
            Navigator.pushReplacementNamed(context, MainScreen.routName);
          },
        )
      ]),
    );
  }
}
