import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/addShippingAddress/components/spacer.dart';

import '../../../../shared/app_style.dart';
import '../../../../shared/text_field.dart';
import 'build_button.dart';
import 'drop_down_contery.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const MySpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "First Name",
                    style: appStyle(
                        14, FontWeight.normal, const Color(0xFF6C6C6C)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: const BuildTextField(
                      hintText: "Enter Your First Name",
                      obscureText: false,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last Name",
                    style: appStyle(
                        14, FontWeight.normal, const Color(0xFF6C6C6C)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.43,
                      child: const BuildTextField(
                        hintText: "Enter Your Last Name",
                        obscureText: false,
                      )),
                ],
              ),
            ],
          ),
          const MySpacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Address",
                style: appStyle(14, FontWeight.normal, const Color(0xFF6C6C6C)),
              ),
              const SizedBox(
                height: 5,
              ),
              const BuildTextField(
                hintText: "Ex: 25 Robert Latouche Street",
                obscureText: false,
                textInputType: TextInputType.streetAddress,
              )
            ],
          ),
          const MySpacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Zipcode (Postal Code)",
                style: appStyle(14, FontWeight.normal, const Color(0xFF6C6C6C)),
              ),
              const SizedBox(
                height: 5,
              ),
              const BuildTextField(
                hintText: "Pham Cong Thanh",
                obscureText: false,
                textInputType: TextInputType.streetAddress,
              )
            ],
          ),
          const MySpacer(),
          const DropDownContry(),
          const MySpacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          SizedBox(
            height: 45,
            child: BuildButton(
              text: 'Save Address',
              color: const Color(0xFF242424),
              ontap: () {},
              textStyle: appStyle(17, FontWeight.w400, Colors.white),
            ),
          )
        ]),
      ),
    );
  }
}
