import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../cubits/getFromCart/get_from_cart_cubit.dart';
import '../../../../../data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/localization.dart';
import 'product_card.dart';

class SlidableDeleteFromCart extends StatelessWidget {
  const SlidableDeleteFromCart({
    super.key,
    required this.img,
    required this.name,
    required this.price,
    required this.index,
    required this.model,
  });
  final String img;
  final String name;
  final String price;
  final int index;
  final GetFromCart model;

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<GetFromCartCubit>(context);
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (context) {
              final cartId = model.details?[index].cartId;
              final prodId = model.details?[index].product?.id;
              if (cartId == null || prodId == null) return;
              cubit.deleteFromCart(cart_id: cartId, product_id: prodId);
            },
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: context.t.tr('delete'),
          ),
        ],
      ),
      child: ProductCard(
        img: img,
        price: price,
        name: name,
      ),
    );
  }
}
