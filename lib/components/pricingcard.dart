import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/utils.dart';

class PricingCard extends StatelessWidget {
  const PricingCard({
    super.key,

    ///1 for basic, 2 for pro & 3 for gold
    required this.type,

    ///Called when user presses on "commander maintenant"
    required this.onCommand,
  });

  final int type;
  final Function() onCommand;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    String categ;
    String pointImage;
    String price;
    Color color;

    List<String> description = [];

    if (type == 0) {
      categ = 'Abonnement';
      pointImage = 'assets/design/images/group-45809-oeR.png';
      price = '2000';
      color = Color(0xff1862f0);
      description.addAll(
        [
          'Accès à la fiche de nos contacts',
          'Pourvoir effectuer des retrait de vos compte',
          'Formation au trading',
          'Accès à notre market place',
        ],
      );
    } else if (type == 1) {
      categ = 'BASIQUE';
      pointImage = 'assets/design/images/group-45809-oeR.png';
      price = '2000';
      color = Color(0xff1862f0);
      description.addAll(
        [
          'Partage de ton service ou produits dans nos différents groupe WhatsApp 1/semaine',
          'Accès à notre market place (3produits ou service)',
        ],
      );
    } else if (type == 2) {
      categ = 'Pro';
      pointImage = 'assets/design/images/group-45809.png';
      price = '5000';
      color = Color(0xff92b127);
      description.addAll(
        [
          'Partage de ton service ou produits dans nos différents groupe WhatsApp 3/semaine',
          'Accès à notre marketplace (6 produits ou services)',
        ],
      );
    } else {
      categ = 'Gold';
      pointImage = 'assets/design/images/group-45809-Dah.png';
      price = '10000';
      color = Color(0xfff49101);
      description.addAll(
        [
          'Partage de ton service ou produits dans nos différents groupe WhatsApp 5/semaine',
          'Accès à notre marketplace (10 produits ou services)',
          'Partage de ton service ou produit sur notre page Facebook',
          'Conception d‘un flyer professionnel',
        ],
      );
    }

    return Container(
      margin: EdgeInsets.fromLTRB(
        0 * fem,
        0 * fem,
        0 * fem,
        15 * fem,
      ),
      padding: EdgeInsets.fromLTRB(
        24 * fem,
        20 * fem,
        24 * fem,
        20 * fem,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffbbc8d4)),
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(24 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 0 * fem, 15 * fem),
            child: Text(
              categ,
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 12 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.3333333333 * ffem / fem,
                letterSpacing: 0.400000006 * fem,
                color: color,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(
              0 * fem,
              4 * fem,
              0 * fem,
              12 * fem,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      0 * fem,
                      0 * fem,
                      0 * fem,
                      0 * fem,
                    ),
                    child: Text(
                      '${price}F',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 36 * ffem,
                        fontWeight: FontWeight.w700,
                        height: 0.4444444444 * ffem / fem,
                        letterSpacing: 0.400000006 * fem,
                        color: color,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                    0 * fem,
                    0 * fem,
                    0 * fem,
                    0 * fem,
                  ),
                  child: Text(
                    type>0?'/mo':'a vie',
                    textAlign: TextAlign.center,
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 12 * ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.3333333333 * ffem / fem,
                      letterSpacing: 0.400000006 * fem,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
            width: 283 * fem,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: description
                    .map(
                      (desc) => Container(
                        margin: EdgeInsets.fromLTRB(
                          0 * fem,
                          0 * fem,
                          0 * fem,
                          8 * fem,
                        ),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // group45809r9X (12:657)
                              margin: EdgeInsets.fromLTRB(
                                0 * fem,
                                0 * fem,
                                21 * fem,
                                1 * fem,
                              ),
                              width: 13 * fem,
                              height: 13 * fem,
                              child: Image.asset(
                                pointImage,
                                width: 13 * fem,
                                height: 13 * fem,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                desc,
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 10 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.6 * ffem / fem,
                                  letterSpacing: 0.400000006 * fem,
                                  color: Color(0xff6d7d8b),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList()),
          ),
          ReusableButton(
            title: 'Commander maintenant',
            onPress: onCommand,
            mainColor: color,
          )
        ],
      ),
    );
  }
}
