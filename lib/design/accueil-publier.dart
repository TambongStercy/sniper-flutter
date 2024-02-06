import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/pricingcard.dart';
import 'package:snipper_frontend/utils.dart';

class Publicite extends StatelessWidget {
  const Publicite({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
      padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 30 * fem),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 14 * fem),
                        constraints: BoxConstraints(
                          maxWidth: 304 * fem,
                        ),
                        child: Text(
                          'Booste ta visibilité grâce à nos outils publicitaires ciblés.',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.3999999762 * ffem / fem,
                            color: Color(0xff25313c),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 15 * fem),
                        child: Text(
                          'Nos Pack Publicitaire ',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.25 * ffem / fem,
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
          PricingCard(
            type: 1,
            onCommand: () {},
          ),
          PricingCard(
            type: 2,
            onCommand: () {},
          ),
          PricingCard(
            type: 3,
            onCommand: () {},
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7 * fem),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
                  child: Text(
                    'Mon pack actif',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 16 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.25 * ffem / fem,
                      color: Color(0xfff49101),
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 0 * fem),
                  width: 339 * fem,
                  height: 50 * fem,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(7 * fem),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3f25313c),
                        offset: Offset(0 * fem, 0 * fem),
                        blurRadius: 2.1500000954 * fem,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Desole vous n’avez pas de pack active. ',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 12 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1.3333333333 * ffem / fem,
                        letterSpacing: 0.400000006 * fem,
                        color: Color(0xff25313c),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
