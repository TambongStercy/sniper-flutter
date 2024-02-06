import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
import 'package:snipper_frontend/components/contactcard.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'dart:ui';
// import 'package:google_fonts/google_fonts.dart';
import 'package:snipper_frontend/utils.dart';

class FicheContact extends StatelessWidget {
  static const id = 'fiche contact';

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SimpleScaffold(
      title: 'Fiche de contact',
      child: Container(
        padding: EdgeInsets.fromLTRB(27 * fem, 25 * fem, 23 * fem, 25 * fem),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0 * fem, 0 * fem, 0 * fem, 10 * fem),
                  child: Text(
                    'Janvier 2024',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14 * ffem,
                      fontWeight: FontWeight.w500,
                      height: 1.4285714286 * ffem / fem,
                      color: Color(0xfff49101),
                    ),
                  ),
                ),
                ContactCard(
                  date: 'Samedi 09/01/2024',
                  onPress: () {},
                ),
              ],
            ),
            SizedBox(height: 10 * fem),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0 * fem, 0 * fem, 0 * fem, 10 * fem),
                  child: Text(
                    'Decembre 2023',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14 * ffem,
                      fontWeight: FontWeight.w500,
                      height: 1.4285714286 * ffem / fem,
                      color: Color(0xfff49101),
                    ),
                  ),
                ),
                ContactCard(
                  date: 'Samedi 09/12/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/12/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/12/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/12/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
              ],
            ),
            SizedBox(height: 10 * fem),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0 * fem, 0 * fem, 0 * fem, 10 * fem),
                  child: Text(
                    'Novembre 2023',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14 * ffem,
                      fontWeight: FontWeight.w500,
                      height: 1.4285714286 * ffem / fem,
                      color: Color(0xfff49101),
                    ),
                  ),
                ),
                ContactCard(
                  date: 'Samedi 09/11/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/11/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/11/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/11/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
              ],
            ),
            SizedBox(height: 10 * fem),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0 * fem, 0 * fem, 0 * fem, 10 * fem),
                  child: Text(
                    'October 2023',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14 * ffem,
                      fontWeight: FontWeight.w500,
                      height: 1.4285714286 * ffem / fem,
                      color: Color(0xfff49101),
                    ),
                  ),
                ),
                ContactCard(
                  date: 'Samedi 09/10/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/10/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/10/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
                ContactCard(
                  date: 'Samedi 09/10/2023',
                  onPress: () {},
                ),
                SizedBox(
                  height: 10 * fem,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
