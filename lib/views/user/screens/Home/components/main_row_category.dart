import 'package:flutter/material.dart';

import 'category_container.dart';
import 'star_category_container.dart';

class BuildCategoryMainRow extends StatelessWidget {
  const BuildCategoryMainRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.only(left: 20),
        child: Row(
          children: [
            BuildStarCategory(),
            BuildCategoryContainer(
              img: "assets/images/category1.png",
            ),
            BuildCategoryContainer(
              img: "assets/images/category2.png",
            ),
            BuildCategoryContainer(
              img: "assets/images/category3.png",
            ),
            BuildCategoryContainer(
              img: "assets/images/category4.png",
            ),
            BuildCategoryContainer(
              img: "assets/images/category5.png",
            ),
            BuildCategoryContainer(
              img: "assets/images/category6.png",
            ),
          ],
        ),
      ),
    );
  }
}
