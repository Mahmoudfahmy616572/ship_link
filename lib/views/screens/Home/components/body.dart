// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/Home/components/favourite_brands.dart';
import 'package:ship_link/views/screens/Home/components/text_field.dart';

import '../../../shared/app_style.dart';
import 'gridle_view.dart';
import 'main_offer_banner.dart';
import 'main_row_category.dart';
import 'text_title.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color(0xFFCDCDCD)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.11,
            ),

            // const LogoAndIconTopScreen(),
            const BuildTextFeild(),

            Expanded(
                child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, int BuildContext) => Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            ProductTextTitle(
                              textStyle:
                                  appStyle(20, FontWeight.w600, Colors.black),
                              text: "Your favorite brands",
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const FavouriteBrands(),
                            const SizedBox(
                              height: 20,
                            ),
                            ProductTextTitle(
                              textStyle:
                                  appStyle(20, FontWeight.w500, Colors.black),
                              text: "DON’T MISS OffersBanar!!",
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const MainOferBanner(),
                            const SizedBox(
                              height: 20,
                            ),
                            ProductTextTitle(
                              textStyle:
                                  appStyle(20, FontWeight.w700, Colors.black),
                              text: 'Category',
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const BuildCategoryMainRow(),
                            const SizedBox(
                              height: 15,
                            ),
                            ProductTextTitle(
                              textStyle:
                                  appStyle(24, FontWeight.w800, Colors.white),
                              text: "Popular Products",
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const BuildGridView(),
                          ],
                        )))
          ],
        ));
  }
}
