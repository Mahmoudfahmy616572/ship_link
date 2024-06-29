import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BuildCategoryContainer extends StatelessWidget {
  BuildCategoryContainer({
    super.key,
    required this.img,
  });
  String? img;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 200,
        height: 65,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: img!,
            errorWidget: (context, url, error) => const Center(
                child: Icon(
              Icons.error_outline,
              size: 60,
            )),
          ),
        ),
      ),
    );
  }
}
