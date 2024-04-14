import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../shared/app_style.dart';
import 'app_bar.dart';
import 'content_user-info.dart';

List<String> listPersonalInfo = <String>[
  "Update Mobile No",
  'Update Password',
];
List<String> listDrivingInfo = <String>[
  "Update Driving Info",
  'Assigned Vehicle',
];

class Body extends StatefulWidget {
  const Body({
    super.key,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String? dropdownValuelistPersonalInfo;
  String? dropdownValuelistDriverInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: const BoxDecoration(
              color: Color(0xFF545454),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              const CustomAppBar(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              const ContentUserInfo(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
            ],
          ),
        ),
        Expanded(
            child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.width * 0.02),
                width: MediaQuery.of(context).size.height * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black),
                child: dropDwonPesonalInfo(),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.width * 0.02),
                width: MediaQuery.of(context).size.height * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black),
                child: dropDrivingInfo(),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.width * 0.02),
                width: MediaQuery.of(context).size.height * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/support.svg"),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      "Support and enquiry",
                      style: appStyle(15, FontWeight.normal, Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ))
      ],
    );
  }

  DropdownButton<String> dropDwonPesonalInfo() {
    return DropdownButton<String>(
      onTap: () {},
      hint: Row(
        children: [
          SvgPicture.asset("assets/icons/editicon.svg"),
          const SizedBox(
            width: 6,
          ),
          const Text(
            "Personal Info",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      value: dropdownValuelistPersonalInfo,
      borderRadius: BorderRadius.circular(15),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 0,
      underline: Container(color: Colors.white),
      style: appStyle(
          17,
          FontWeight.w700,
          const Color(
            0xFFCDCDCD,
          )),
      dropdownColor: Colors.black,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        dropdownValuelistPersonalInfo = value ?? "";
        setState(() {
          dropdownValuelistPersonalInfo = value!;
        });
        // switch (value) {
        //   case "User":
        //     Navigator.pushNamed(context, UserRegister.routName);
        //     break;
        //   case "Driver":
        //     Navigator.pushNamed(context, DriverRegister.routName);
        //     break;
        //   case "Provider":
        //     Navigator.pushNamed(context, ProviderRegister.routName);

        //     break;
        // }
      },
      items: listPersonalInfo.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  DropdownButton<String> dropDrivingInfo() {
    return DropdownButton<String>(
      onTap: () {},
      hint: Row(
        children: [
          SvgPicture.asset("assets/icons/editicon.svg"),
          const SizedBox(
            width: 6,
          ),
          const Text(
            "Driving Info",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      value: dropdownValuelistDriverInfo,
      borderRadius: BorderRadius.circular(15),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 0,
      underline: Container(color: Colors.white),
      style: appStyle(
          17,
          FontWeight.w700,
          const Color(
            0xFFCDCDCD,
          )),
      dropdownColor: Colors.black,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        dropdownValuelistDriverInfo = value ?? "";
        setState(() {
          dropdownValuelistDriverInfo = value!;
        });
        // switch (value) {
        //   case "User":
        //     Navigator.pushNamed(context, UserRegister.routName);
        //     break;
        //   case "Driver":
        //     Navigator.pushNamed(context, DriverRegister.routName);
        //     break;
        //   case "Provider":
        //     Navigator.pushNamed(context, ProviderRegister.routName);

        //     break;
        // }
      },
      items: listDrivingInfo.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
