import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/addPaymentMethod/components/custom_credit_card.dart';
import 'package:ship_link/views/user/screens/checkOut/check_out.dart';

import '../../../../shared/build_elevation_button.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final GlobalKey<FormState> formKey = GlobalKey();
  AutovalidateMode? autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CustomCreditCard(
            formKey: formKey,
            autovalidateMode: autovalidateMode,
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CheckoutButton(
                text: 'Complete payment',
                ontap: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    Navigator.pushNamed(context, CheckOut.routName);
                  } else {
                    autovalidateMode = AutovalidateMode.always;
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
