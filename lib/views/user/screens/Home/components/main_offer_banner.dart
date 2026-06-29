import 'package:flutter/material.dart';
import 'package:ship_link/data/models/allProducts/all_products.dart';
import 'package:ship_link/views/user/screens/Home/components/offers_bannar.dart';

class MainOferBanner extends StatelessWidget {
  const MainOferBanner({
    super.key,
    required this.offerProducts,
  });

  final List<Product> offerProducts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: offerProducts.map((p) {
          final discount = _randomDiscount(p.id ?? 0);
          return OffersBanar(
            product: p,
            offerNum: "$discount%",
          );
        }).toList(),
      ),
    );
  }

  int _randomDiscount(int id) {
    return [30, 15, 10, 25, 20, 40][id % 6];
  }
}
