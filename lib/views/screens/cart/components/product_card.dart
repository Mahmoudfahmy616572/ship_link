import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/favourite/Components/button_shopping.dart';
import 'package:ship_link/views/screens/favourite/Components/cart.dart';

import '../../favourite/Components/name_and_price.dart';
import '../../favourite/Components/product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.cart,
  });
  final Cart cart;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF606060)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ProductImage(
                image: cart.product.images[0],
              ),
              const SizedBox(
                width: 30,
              ),
              NameAndPrice(
                price: "\$${cart.product.price}",
                title: cart.product.title,
              ),
            ],
          ),
          const Text("  "),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ButtonDeleteproduct(),
              SizedBox(
                height: 35,
              ),
              ButtonShoppingbag(),
            ],
          )
        ],
      ),
    );
  }
}
