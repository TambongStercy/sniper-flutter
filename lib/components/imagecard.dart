import 'package:flutter/material.dart';
// import 'package:snipper_frontend/utils.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    return Container(
      margin: EdgeInsets.fromLTRB(
        0 * fem,
        0 * fem,
        0 * fem,
        15 * fem,
      ),
      width: 340 * fem,
      height: 240 * fem,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12 * fem),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            image,
          ),
        ),
      ),
    );
  }
}
