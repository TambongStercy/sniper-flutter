import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/imagecard.dart';
import 'package:snipper_frontend/utils.dart';

class PrdtPost extends StatelessWidget {
  const PrdtPost({
    super.key,
    required this.image,
    required this.onContact,
    required this.title,
  });

  final String image;
  final String title;
  final Function() onContact;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      // group45857s1b (290:1471)
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 1 * fem, 0 * fem),
      width: 340 * fem,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // marketplacecarousel1bTP (290:1473)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageCard(
                    image: image,
                  ),
                  Center(
                    // servicedelivraisonzkR (I290:1473;281:1381)
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 20 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1 * ffem / fem,
                          color: Color(0xff25313c),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ReusableButton(
            title: 'Contacter maintenant',
            onPress: onContact,
          ),
        ],
      ),
    );
  }
}
