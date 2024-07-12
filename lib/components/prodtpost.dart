import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/imagecard.dart';
// import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';

class PrdtPost extends StatelessWidget {
  const PrdtPost({
    super.key,
    required this.image,
    required this.onContact,
    required this.title,
    required this.price,
    this.rating = null,
  });

  final String image;
  final String title;
  final int price;
  final Function() onContact;
  final Widget? rating;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      padding: EdgeInsets.fromLTRB(20 * fem, 0 * fem, 20 * fem, 0 * fem),
      width: 340 * fem,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageCard(
                    network: true,
                    image: image,
                    rating: rating,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 220,
                          child: Text(
                            title,
                            textAlign: TextAlign.left,
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 20 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1 * ffem / fem,
                              color: Color(0xff25313c),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0,),
                        Container(
                          child: Text(
                            price == 0 ? 'GRATUIT' : '${formatAmount(price)} FCFA',
                            textAlign: TextAlign.left,
                            style: SafeGoogleFont(
                              'Mulish',
                              fontSize: 17 * ffem,
                              fontWeight: FontWeight.w800,
                              height: 1.255 * ffem / fem,
                              color: Color(0xfff49101),
                            ),
                          ),
                        ),
                      ],
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
          Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
