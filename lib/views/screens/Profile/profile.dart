// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/views/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/shared/app_style.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  static String routName = '/Profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F2F2F),
        title: Text(
          "Home",
          style: appStyle(18, FontWeight.w600, Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, MainScreen.routName);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          const SettingText(),
          const Space(),
          const ImgProfile(),
          const Space(),
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, int BuildContext) => Column(
                children: [
                  const BuildAlterContainer(),
                  const Space(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                    height: 125,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF6F6F6).withOpacity(0.2)),
                    child: const Column(
                      children: [
                        EditProfile(),
                        Dividerr(),
                        BankData(),
                        Dividerr(),
                        Contacts(),
                      ],
                    ),
                  ),
                  const Space(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                    height: 125,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF6F6F6).withOpacity(0.2)),
                    child: const Column(
                      children: [
                        Privecy(),
                        Dividerr(),
                        Safety(),
                        Dividerr(),
                        TwoFactor(),
                      ],
                    ),
                  ),
                  const Space(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                    height: 210,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF6F6F6).withOpacity(0.2)),
                    child: const Column(
                      children: [
                        Theme(),
                        Dividerr(),
                        SwitchAccount(),
                        Dividerr(),
                        AddNewAccount(),
                        Dividerr(),
                        Help(),
                        Dividerr(),
                        LogOut(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class LogOut extends StatelessWidget {
  const LogOut({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/log out.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "log out",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class Help extends StatelessWidget {
  const Help({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/Help.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Help",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class AddNewAccount extends StatelessWidget {
  const AddNewAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/add new account.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "add new account",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class SwitchAccount extends StatelessWidget {
  const SwitchAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/switch account.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "switch account",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class Theme extends StatelessWidget {
  const Theme({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/Theme.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Theme",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class TwoFactor extends StatelessWidget {
  const TwoFactor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/Two-factor authentication.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Two-factor authentication",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class Safety extends StatelessWidget {
  const Safety({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/Safety.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Safety",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class Privecy extends StatelessWidget {
  const Privecy({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/Privacy.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Privacy",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class Contacts extends StatelessWidget {
  const Contacts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/contact.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Contacts",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class BankData extends StatelessWidget {
  const BankData({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/bank data.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Bank data",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class EditProfile extends StatelessWidget {
  const EditProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset("assets/icons/edit profile.svg"),
      const SizedBox(
        width: 10,
      ),
      Text(
        "Edit profile",
        style: appStyle(15, FontWeight.w600, Colors.white),
      )
    ]);
  }
}

class BuildAlterContainer extends StatelessWidget {
  const BuildAlterContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFF6F6F6).withOpacity(0.2)),
      child: Row(children: [
        SvgPicture.asset("assets/icons/alert.svg"),
        const SizedBox(
          width: 10,
        ),
        Text(
          "Alerts",
          style: appStyle(15, FontWeight.w600, Colors.white),
        )
      ]),
    );
  }
}

class ImgProfile extends StatelessWidget {
  const ImgProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage("assets/images/mahmoud.jpg"),
          radius: 45,
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fahmy',
              style: appStyle(20, FontWeight.bold, Colors.white),
            ),
            Text(
              'Fahmy123@gmail.com',
              style: appStyle(14, FontWeight.normal, Colors.white),
            ),
            Text(
              'Egypt,Dakahlia',
              style: appStyle(14, FontWeight.normal, Colors.white),
            )
          ],
        )
      ],
    );
  }
}

class SettingText extends StatelessWidget {
  const SettingText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Settings",
          style: appStyle(25, FontWeight.bold, Colors.white),
        )
      ],
    );
  }
}

class Dividerr extends StatelessWidget {
  const Dividerr({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 30),
      child: Divider(
        color: Color(0xFFF6F6F6),
        thickness: 0.5,
      ),
    );
  }
}

class Space extends StatelessWidget {
  const Space({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 35,
    );
  }
}
