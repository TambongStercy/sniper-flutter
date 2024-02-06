import 'package:flutter/material.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/utils.dart';

class NotifBox extends StatelessWidget {
  const NotifBox({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return GestureDetector(
      onTap: () {
        Navigator.popAndPushNamed(context, Wallet.id);
        print(message);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          9.64 * fem,
          7 * fem,
          15 * fem,
          18 * fem,
        ),
        width: 340 * fem,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(
                0 * fem,
                0 * fem,
                0 * fem,
                3 * fem,
              ),
              width: 9 * fem,
              height: 9 * fem,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.5 * fem),
                color: Color(0xfff49101),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                0 * fem,
                0 * fem,
                2 * fem,
                0 * fem,
              ),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                      0 * fem,
                      0 * fem,
                      27.66 * fem,
                      2 * fem,
                    ),
                    width: 29.7 * fem,
                    height: 32.79 * fem,
                    child: Image.asset(
                      'assets/design/images/bellbadgefill-3iR.png',
                      width: 29.7 * fem,
                      height: 32.79 * fem,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      message,
                      softWrap: true,
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 13 * ffem,
                        fontWeight: FontWeight.w400,
                        height: 1.3846153846 * ffem / fem,
                        color: Color(0xff6d7d8b),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
