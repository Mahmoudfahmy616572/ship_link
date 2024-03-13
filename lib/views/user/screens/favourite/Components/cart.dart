import '../../product/components/product_list.dart';

class Cart {
  final Product product;
  final int numOfItems;

  Cart({required this.product, required this.numOfItems});
}

List<Cart> demoCarts = [
  Cart(product: demoProduct[0], numOfItems: 2),
  Cart(product: demoProduct[1], numOfItems: 1),
  Cart(product: demoProduct[2], numOfItems: 1),
  Cart(product: demoProduct[3], numOfItems: 1),
  Cart(product: demoProduct[4], numOfItems: 1),
  Cart(product: demoProduct[2], numOfItems: 1),
  Cart(product: demoProduct[3], numOfItems: 1),
  Cart(product: demoProduct[1], numOfItems: 1),
];
