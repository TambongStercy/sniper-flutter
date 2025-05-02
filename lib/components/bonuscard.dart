import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

class BonusCard extends StatelessWidget {
  const BonusCard({
    super.key,
    required this.type,
    required this.percentage,
  });

  ///1 for basic, 2 for pro & 3 for gold
  final int type;

  ///Called when user presses on "commander maintenant"
  final double percentage;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    String categ;
    double perc = percentage;
    String price;
    Color color;
    IconData icon;
    String good;
    String path = 'tshirtfill.png';

    if (type == 1) {
      categ = context.translate('pack_basic');
      price = '2000';
      icon = Icons.directions_walk_sharp;
      good = 'UN T-SHIRT ET UNE CASQUETTE DE LA SBC';
      color = Theme.of(context).colorScheme.primary;
    } else if (type == 2) {
      categ = 'Pro';
      price = '500,000';
      good = 'UNE MONTRE';
      icon = Icons.watch;
      color = Theme.of(context).colorScheme.secondary;
    } else {
      categ = 'Gold';
      price = '1,000,000';
      good = 'UN IPHONE 11 PRO MAX';
      icon = Icons.phone_android_outlined;
      color = Theme.of(context).colorScheme.tertiary;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 0 * fem),
      padding: EdgeInsets.fromLTRB(20 * fem, 15 * fem, 26 * fem, 20 * fem),
      width: 339 * fem,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffdae3ea)),
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(11 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categ,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w500,
              height: 1.3333333333 * ffem / fem,
              letterSpacing: 0.400000006 * fem,
              color: color,
            ),
          ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 5 * fem, 4 * fem, 0 * fem),
                    child: RichText(
                      text: TextSpan(
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 13 * ffem,
                          fontWeight: FontWeight.w500,
                          height: 1.4 * ffem / fem,
                          color: Color(0xff25313c),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: price,
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 20 * ffem,
                              fontWeight: FontWeight.w800,
                              height: 1.4 * ffem / fem,
                              color: color,
                            ),
                          ),
                          TextSpan(
                            text: ' FCFA\n',
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 20 * ffem,
                              fontWeight: FontWeight.w800,
                              height: 1.4 * ffem / fem,
                              color: Color(0xff25313c),
                            ),
                          ),
                          TextSpan(
                            text: '+  $good.',
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 4 * fem, 0 * fem),
                  child: type == 1
                      ? Image.asset('assets/design/images/$path')
                      : Icon(icon),
                  height: 20,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              // width: 25 * fem,
              // height: 18 * fem,
              child: Text(
                '${perc.toStringAsFixed(2)}%',
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 10 * ffem,
                  fontWeight: FontWeight.w500,
                  height: 1.8 * ffem / fem,
                  letterSpacing: 0.4600000083 * fem,
                  color: color,
                ),
              ),
            ),
          ),
          LinearProgressIndicator(
            minHeight: 6.0,
            value: perc > 100 ? 100 : perc / 100,
            borderRadius: BorderRadius.circular(12),
            color: color,
          ),
        ],
      ),
    );
  }
}

//  RichText(
//               text: TextSpan(
//                 style: SafeGoogleFont(
//                   'Montserrat',
//                   fontSize: 15 * ffem,
//                   fontWeight: FontWeight.w500,
//                   height: 1.4 * ffem / fem,
//                   color: Color(0xff25313c),
//                 ),
//                 children: <TextSpan>[
//                   const TextSpan(
//                     text: 'Bienvenue ',
//                   ),
//                   TextSpan(
//                     text: name?.toUpperCase(),
//                     style: SafeGoogleFont(
//                       'Montserrat',
//                       fontSize: 15 * ffem,
//                       fontWeight: FontWeight.w500,
//                       height: 1.4 * ffem / fem,
//                       color: limeGreen,
//                     ),
//                   ),
//                   const TextSpan(
//                     text:
//                         ' à la sniper Business Center, la communauté la plus dynamique du Cameroun.',
//                   )
//                 ],
//               ),
//             );