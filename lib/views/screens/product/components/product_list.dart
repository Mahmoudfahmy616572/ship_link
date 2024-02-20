import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.title,
    required this.description,
    required this.price,
    this.rating = 0.0,
    required this.images,
    required this.colors,
    this.isFavourite = false,
    this.isPopular = false,
  });
  final String title, description;
  final double price, rating;
  final List<String> images;
  final List<Color> colors;
  final bool isFavourite, isPopular;
}

List<Product> demoProduct = [
  const Product(
      rating: 4.8,
      title: 'Wireless ',
      description: description,
      price: 64.99,
      images: [
        "assets/images/glassess.png",
      ],
      colors: [
        Color(0xFFf6625E),
        Color(0xFF836DB8),
        Color(0xFFDECB9C),
      ],
      isFavourite: true,
      isPopular: true),
  const Product(
    isPopular: true,
    rating: 4.8,
    title: 'Glasses',
    description: description,
    price: 78.99,
    images: [
      "assets/images/category2.png",
    ],
    colors: [
      Color(0xFFf6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      Colors.white
    ],
  ),
  const Product(
      rating: 3.6,
      title: 'Gloves ',
      description: description,
      price: 43.6,
      images: [
        "assets/images/category4.png",
      ],
      colors: [
        Color(0xFFf6625E),
        Color(0xFF836DB8),
        Color(0xFFDECB9C),
        Colors.white
      ],
      isFavourite: true,
      isPopular: true),
  const Product(
    rating: 3.6,
    title: 'Logitech head',
    description: description,
    price: 44.6,
    images: [
      "assets/images/category6.png",
    ],
    colors: [
      Color(0xFFf6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      Colors.white
    ],
    isFavourite: true,
  ),
  const Product(
    rating: 3.6,
    title: 'Logitech head',
    description: description,
    price: 23.6,
    images: [
      "assets/images/category1.png",
    ],
    colors: [
      Color(0xFFf6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      Colors.white
    ],
    isFavourite: true,
  ),
];

const String description =
    "Wireless Controller for PS4™ gives you what you want in your gaming from over precision control your games to sharing …";
