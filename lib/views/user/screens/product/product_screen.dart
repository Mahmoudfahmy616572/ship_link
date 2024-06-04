import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubitallProducts/cubit.dart';

import '../../../../cubitallProducts/product_stat.dart';
import '../../../shared/app_style.dart';
import 'components/add_subtract_btn.dart';
import 'components/button_add_to_cart.dart';
import 'components/rating_row.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key,});
  static String routName = '/productScreen';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {},

      builder: (context, state) {
        var cubit = ProductCubit.get(context);
        return Scaffold(
            backgroundColor: const Color(0xFFD9D9D9),
            body:
                 SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          SizedBox(
                              width: double.infinity,
                              height: 289,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  cubit.getSingleProduct.products?.image ??
                                      "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBwgHBgkIBwgKCgkLDRYPDQwMDRsUFRAWIB0iIiAdHx8kKDQsJCYxJx8fLT0tMTU3Ojo6Iys/RD84QzQ5OjcBCgoKDQwNGg8PGjclHyU3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3N//AABEIAJQA/QMBIgACEQEDEQH/xAAYAAEBAQEBAAAAAAAAAAAAAAAAAQIDBv/EABgQAQEBAQEAAAAAAAAAAAAAAAARATES/8QAGQEBAQEBAQEAAAAAAAAAAAAAAAECAwcG/8QAFhEBAQEAAAAAAAAAAAAAAAAAABEB/9oADAMBAAIRAxEAPwDygD516+AAAAAAAKAgQURQAAAQgqAoKggoigAIAAAAAACBVgBU3VRRMXQpTEi8CgUoFKkIC0qEBSmpAq0QwFTTSCC1IQKtKgK0JSpFURQAAAEEqCxphIRShU4tTdQStVNSgVYQzVoUClCpFpUCrSs0oVd0QoVTNRQqlSpQqkMWi1DCEFWlSAtVcZxc0VQGRlWVrTmURKC6hU1Yi0ZCK3SshBsYzWqCoJQNSlRcRVxlcBaVNZSDXorK4o1mrmstJqtUrKoL1NwxRUXE0ouNCYqNOdEGo5KmiasAQCgAgAKuNM4oKgJBARQVAKqAIKgDVMZawVrFRWVMVFwDUVNFXFTAbcgGnIFQEFQIKAAAqiLggKFGdDUABcCIKBEACC4i4GNYrKorRiLiCpqpoq4IDWMwVGq5iKhRBTARcAAFwEVcEBFBWUahoMxTFWozoqAI0gIuC4Chiopi4YqAmqmi5i4m9XAaRFhBhE1QGRYLURQKAKAC4CLCLUXETWtQGRTVGRVKiJGkKJBYpQxc6CKpTUFhoA1Ai4ClKkIMQhFqboiCkBBdxAAWKhBaiNRakWAsKaQDcSLAozCJFpQiRYUoRCC0Ii1CCwCEGhcMBQUQQ0FRABDFARNTQEGs4AYgA2oAAAGoAAAAAAAGKAAAoAguAA//2Q==",
                                  fit: BoxFit.cover,
                                ),
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.055,
                          ),
                          Text(
                            cubit.getSingleProduct.products?.name ?? "dddd",
                            style: appStyle(22, FontWeight.w600, Colors.black),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\$ ${cubit.getSingleProduct.products?.price ?? "33"}",
                                style:
                                    appStyle(22, FontWeight.w600, Colors.black),
                              ),
                              Row(
                                children: [
                                  AddOrSubtractButton(
                                    ontap: () {},
                                    icon: Icons.add,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Text("01",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          letterSpacing: 2)),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  AddOrSubtractButton(
                                    ontap: () {},
                                    icon: Icons.remove,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const RaitingRow(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.09,
                          ),
                          BuildButtonAddToCart(
                            ontap: () {},
                            text: "Add to cart",
                            img: "assets/icons/saveIcon.svg",
                          )
                        ],
                      ),
                    ),
                  )
               );
      },
    );
  }
}
