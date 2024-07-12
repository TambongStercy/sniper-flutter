import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.image,
    this.network = false,
    this.rating = null,
  });

  final String image;
  final bool network;
  final Widget ?rating;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    final imageWidget = network ?  NetworkImage(image): AssetImage(image) as ImageProvider<Object>;

    return Container(
      margin: EdgeInsets.fromLTRB(
        0 * fem,
        0 * fem,
        0 * fem,
        15 * fem,
      ),
      child: rating,
      width: 320 * fem,
      height: 220 * fem,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12 * fem),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: imageWidget,
        ),
      ),
    );
  }
}
