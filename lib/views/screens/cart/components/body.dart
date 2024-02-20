import 'package:flutter/material.dart';

import '../../favourite/Components/cart.dart';
import 'dismissable_container.dart';
import 'product_card.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20),
      child: ListView.builder(
        itemCount: demoCarts.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Dismissible(
                  key: Key(demoCarts[index].product.toString()),
                  direction: DismissDirection.endToStart,
                  background: const DismissibleContainer(),
                  // onDismissed: (direction) {
                  //   setState(() {
                  //     demoCarts.removeAt(index);
                  //   });
                  // },
                  child: ProductCard(
                    cart: demoCarts[index],
                  )),
            ],
          );
        },
      ),
    );
  }
}
