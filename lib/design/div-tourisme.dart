import 'package:flutter/material.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import your localization extension

class Scene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    
    return Container(
      width: double.infinity,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 13 * fem),
              padding: EdgeInsets.fromLTRB(0 * fem, 6 * fem, 0 * fem, 1 * fem),
              width: double.infinity,
              height: 105 * fem,
              decoration: BoxDecoration(
                color: Color(0xff25313c),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3f92b127),
                    offset: Offset(0 * fem, 2 * fem),
                    blurRadius: 5 * fem,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        55 * fem, 0 * fem, 26.7 * fem, 0 * fem),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 75.3 * fem, 9 * fem),
                          width: 6 * fem,
                          height: 6 * fem,
                          child: Image.asset(
                            'assets/design/images/mic-cam-6QH.png',
                            width: 6 * fem,
                            height: 6 * fem,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 17 * fem,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 194 * fem, 0 * fem),
                                  child: Text(
                                    '09:41',
                                    textAlign: TextAlign.center,
                                    style: SafeGoogleFont(
                                      'SF Pro Text',
                                      fontSize: 17 * ffem,
                                      fontWeight: FontWeight.w600,
                                      height: 1 * ffem / fem,
                                      letterSpacing: -0.5 * fem,
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 2 * fem, 0 * fem, 2 * fem),
                                height: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 6 * fem, 0 * fem),
                                      width: 19.97 * fem,
                                      height: 12 * fem,
                                      child: Image.asset(
                                        'assets/design/images/elements-signal-wwP.png',
                                        width: 19.97 * fem,
                                        height: 12 * fem,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 6 * fem, 0 * fem),
                                      width: 17 * fem,
                                      height: 12.5 * fem,
                                      child: Image.asset(
                                        'assets/design/images/elements-connection-ANm.png',
                                        width: 17 * fem,
                                        height: 12.5 * fem,
                                      ),
                                    ),
                                    Container(
                                      width: 27.33 * fem,
                                      height: 13 * fem,
                                      child: Image.asset(
                                        'assets/design/images/elements-battery-moP.png',
                                        width: 27.33 * fem,
                                        height: 13 * fem,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        16 * fem, 11.5 * fem, 20.88 * fem, 11.5 * fem),
                    width: double.infinity,
                    height: 56 * fem,
                    decoration: BoxDecoration(
                      color: Color(0xff25313c),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 168 * fem, 0 * fem),
                          height: double.infinity,
                          child: Center(
                            child: SizedBox(
                              width: 83 * fem,
                              height: 33 * fem,
                              child: Image.asset(
                                'assets/design/images/logo-sbc-final-1-6ch.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 4.5 * fem, 0 * fem, 4.5 * fem),
                          height: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 15 * fem, 0 * fem),
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Container(
                                    width: 24 * fem,
                                    height: 24 * fem,
                                    child: Image.asset(
                                      'assets/design/images/wallet-LDP.png',
                                      width: 24 * fem,
                                      height: 24 * fem,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 15 * fem, 0 * fem),
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Container(
                                    width: 24.12 * fem,
                                    height: 24 * fem,
                                    child: Image.asset(
                                      'assets/design/images/trailing-icon-1-QzD.png',
                                      width: 24.12 * fem,
                                      height: 24 * fem,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Container(
                                  width: 24 * fem,
                                  height: 24 * fem,
                                  child: Image.asset(
                                    'assets/design/images/supervisedusercircle-WCR.png',
                                    width: 24 * fem,
                                    height: 24 * fem,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(24 * fem, 0 * fem, 25 * fem, 6 * fem),
              width: double.infinity,
              height: 639 * fem,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 1 * fem, 20 * fem),
                    width: 340 * fem,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
                          child: Text(
                            context.translate('past_events'), // Translated string
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 16 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.25 * ffem / fem,
                              color: Color(0xfff49101),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Container(
                            width: double.infinity,
                            child: Center(
                              child: SizedBox(
                                width: 340 * fem,
                                height: 240 * fem,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24 * fem),
                                  child: Image.asset(
                                    'assets/design/images/rectangle-2771-54d.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 0 * fem),
                    width: 340 * fem,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(6 * fem, 0 * fem, 0 * fem, 15 * fem),
                          child: Text(
                            context.translate('upcoming_events'), // Translated string
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
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 340 * fem,
                                height: 240 * fem,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24 * fem),
                                  child: Image.asset(
                                    'assets/design/images/rectangle-2771-cNm.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10 * fem),
                              Text(
                                context.translate('visit_waza_park'), // Translated string
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25 * ffem / fem,
                                  color: Color(0xff25313c),
                                ),
                              ),
                              SizedBox(height: 10 * fem),
                              Container(
                                width: double.infinity,
                                height: 40 * fem,
                                decoration: BoxDecoration(
                                  color: Color(0xff1862f0),
                                  borderRadius: BorderRadius.circular(66 * fem),
                                ),
                                child: Center(
                                  child: Center(
                                    child: Text(
                                      context.translate('book_now'), // Translated string
                                      textAlign: TextAlign.center,
                                      style: SafeGoogleFont(
                                        'Montserrat',
                                        fontSize: 15 * ffem,
                                        fontWeight: FontWeight.w600,
                                        height: 1.6 * ffem / fem,
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 391 * fem,
              height: 94 * fem,
              decoration: BoxDecoration(
                color: Color(0xfff1f5fb),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Container(
                        padding:
                            EdgeInsets.fromLTRB(7.1 * fem, 21 * fem, 7.1 * fem, 19 * fem),
                        height: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 6 * fem),
                              width: 64 * fem,
                              height: 32 * fem,
                              child: Image.asset(
                                'assets/design/images/icon-DY5.png',
                                width: 64 * fem,
                                height: 32 * fem,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
                              child: Text(
                                context.translate('home'), // Translated string
                                textAlign: TextAlign.center,
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 10 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6 * ffem / fem,
                                  letterSpacing: 0.4 * fem,
                                  color: Color(0xff141b2c),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                            19.1 * fem, 28.96 * fem, 19.1 * fem, 21 * fem),
                        height: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0.01 * fem, 12.27 * fem),
                              width: 27.57 * fem,
                              height: 15.77 * fem,
                              child: Image.asset(
                                'assets/design/images/shareplay-Hww.png',
                                width: 27.57 * fem,
                                height: 15.77 * fem,
                              ),
                            ),
                            Text(
                              context.translate('publish'), // Translated string
                              textAlign: TextAlign.center,
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 10 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.6 * ffem / fem,
                                letterSpacing: 0.4 * fem,
                                color: Color(0xff444746),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 156.4 * fem,
                      height: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0 * fem,
                            top: 0 * fem,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    3.6 * fem, 21 * fem, 3.6 * fem, 19 * fem),
                                width: 78.2 * fem,
                                height: 94 * fem,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 6 * fem),
                                      width: 64 * fem,
                                      height: 32 * fem,
                                      child: Image.asset(
                                        'assets/design/images/icon-d9B.png',
                                        width: 64 * fem,
                                        height: 32 * fem,
                                      ),
                                    ),
                                    Text(
                                      context.translate('marketplace'), // Translated string
                                      textAlign: TextAlign.center,
                                      style: SafeGoogleFont(
                                        'Montserrat',
                                        fontSize: 10 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.6 * ffem / fem,
                                        letterSpacing: 0.4 * fem,
                                        color: Color(0xff444746),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 78.1999511719 * fem,
                            top: 0 * fem,
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(0 * fem, 17 * fem, 0 * fem, 15 * fem),
                              width: 78.2 * fem,
                              height: 94 * fem,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 6 * fem),
                                    width: 104 * fem,
                                    height: 40 * fem,
                                    child: Image.asset(
                                      'assets/design/images/icon-Zvh.png',
                                      width: 104 * fem,
                                      height: 40 * fem,
                                    ),
                                  ),
                                  Text(
                                    context.translate('entertainment_tourism'), // Translated string
                                    textAlign: TextAlign.center,
                                    style: SafeGoogleFont(
                                      'Montserrat',
                                      fontSize: 10 * ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6 * ffem / fem,
                                      letterSpacing: 0.4 * fem,
                                      color: Color(0xff444746),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0 * fem, 21 * fem, 0 * fem, 19 * fem),
                        width: 78.2 * fem,
                        height: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 6 * fem),
                              width: 64 * fem,
                              height: 32 * fem,
                              child: Image.asset(
                                'assets/design/images/icon-JKb.png',
                                width: 64 * fem,
                                height: 32 * fem,
                              ),
                            ),
                            Text(
                              context.translate('investment'), // Translated string
                              textAlign: TextAlign.center,
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 10 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.6 * ffem / fem,
                                letterSpacing: 0.4 * fem,
                                color: Color(0xff444746),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
