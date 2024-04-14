import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class NotificationBoxMsg extends StatelessWidget {
  const NotificationBoxMsg({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: MediaQuery.of(context).size.height * 0.01),
          width: MediaQuery.of(context).size.width * 0.92,
          height: 40,
          decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: Text(
            "Today,5:45 PM",
            style: appStyle(15, FontWeight.normal, const Color(0xFFCDCDCD)),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: MediaQuery.of(context).size.height * 0.01),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.92,
          height: 70,
          decoration: const BoxDecoration(
              color: Color(0xFF545454),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Text(
            "A shipment has been prepared and will be shipped within two days at 4:00 pm",
            style: appStyle(15, FontWeight.normal, const Color(0xFFCDCDCD)),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        )
      ],
    );
  }
}
