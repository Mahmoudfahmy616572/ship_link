import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../cubits/getFromCart/get_from_cart_cubit.dart';
import '../../../../../data/models/getFromCart/get_from_cart.dart';
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
              print(model.details?[index].cartId);
              cubit.deleteFromCart(
                  cart_id: model.details?[index].cartId,
                  product_id: model.details?[index].product?.id);
            },
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
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
