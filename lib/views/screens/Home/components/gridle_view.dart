import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'grid_cart.dart';

class BuildGridView extends StatelessWidget {
  const BuildGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        crossAxisSpacing: 20,
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(2),
          child: DesignGridCard(
            index: index,
          ),
        ),
      ),
    );
  }
}
