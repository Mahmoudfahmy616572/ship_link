import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/Home/components/offers_bannar.dart';

class MainOferBanner extends StatelessWidget {
  const MainOferBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          OffersBanar(
            img: "assets/images/Image Banner 2.png",
            offerNum: "30%",
          ),
          OffersBanar(
            img: "assets/images/Image Banner 3.png",
            offerNum: "15%",
          ),
          OffersBanar(
            img: "assets/images/Image Banner 2.png",
            offerNum: "10%",
          ),
        ],
      ),
    );
  }
}
