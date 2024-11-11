import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/imagecard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension

class Divertissement extends StatelessWidget {
  const Divertissement({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
        padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
              child: Text(
                context.translate('past_outings'),
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 16 * ffem,
                  fontWeight: FontWeight.w600,
                  height: 1.25 * ffem / fem,
                  color: Color(0xfff49101),
                ),
              ),
            ),
            const ImageCard(
              image: 'assets/design/images/rectangle-2771-54d.png',
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
              child: Text(
                context.translate('upcoming'),
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 16 * ffem,
                  fontWeight: FontWeight.w600,
                  height: 1.25 * ffem / fem,
                  color: Color(0xfff49101),
                ),
              ),
            ),
            const ImageCard(
              image: 'assets/design/images/rectangle-2771-cNm.png',
            ),
            SizedBox(
              height: 10 * fem,
            ),
            Text(
              context.translate('waza_park_visit'),
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 16 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.25 * ffem / fem,
                color: Color(0xff25313c),
              ),
            ),
            SizedBox(
              height: 10 * fem,
            ),
            ReusableButton(
              title: context.translate('book_now'),
              lite: false,
              onPress: () {},
            ),
          ],
        ),
      ),
    );
  }
}
