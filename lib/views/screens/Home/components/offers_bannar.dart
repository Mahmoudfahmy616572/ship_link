import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

class OffersBanar extends StatelessWidget {
  const OffersBanar({
    super.key,
    required this.img,
    required this.offerNum,
  });
  final String img;
  final String offerNum;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 220,
        height: 93,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Image.asset(
                img,
                fit: BoxFit.fitHeight,
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  const Color(0xFF343434).withOpacity(0.4),
                  const Color(0xFF343434).withOpacity(0.14)
                ])),
              ),
              Positioned(
                  bottom: 5,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    width: 70,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      "Let's Go",
                      style: appStyle(14, FontWeight.normal, Colors.white),
                    ),
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      const TextSpan(
                          text: 'Get Special Discount\n',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400)),
                      const TextSpan(
                          text: 'Up to  ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                      TextSpan(
                          text: offerNum,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ])),
              )
            ],
          ),
        ),
      ),
    );
  }
}
