import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';
import '../../favourite/Components/button_shopping.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.img,
    required this.name,
    required this.price,
  });
  final String img;
  final String name;
  final String price;
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
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: AspectRatio(
                    
                    aspectRatio: 1.6 / 1.5,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: img,
                      errorWidget: (context, url, error) => const Center(
                          child: Icon(
                        Icons.error_outline,
                        size: 60,
                      )),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              Container(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: appStyle(
                          17, FontWeight.w500, const Color(0xFF606060)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      price,
                      style: appStyle(17, FontWeight.w500, Colors.black),
                    ),
                  ],
                ),
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
