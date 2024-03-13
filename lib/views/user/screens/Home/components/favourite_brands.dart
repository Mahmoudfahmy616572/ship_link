import 'package:flutter/material.dart';

class FavouriteBrands extends StatelessWidget {
  const FavouriteBrands({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 35,
              )),
          Image.asset("assets/images/apple.png"),
          Image.asset("assets/images/bmw.png"),
          Image.asset("assets/images/zara.png"),
          Image.asset("assets/images/zara.png"),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 35,
              )),
        ],
      ),
    );
  }
}
