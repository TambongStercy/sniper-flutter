import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
// import 'package:google_fonts/google_fonts.dart';
import 'package:snipper_frontend/utils.dart';

class Scene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      width: double.infinity,
      child: Container(
        // divtourismeD7P (124:824)
        width: double.infinity,
        decoration: BoxDecoration (
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // group45818k7K (124:825)
              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 13*fem),
              padding: EdgeInsets.fromLTRB(0*fem, 6*fem, 0*fem, 1*fem),
              width: double.infinity,
              height: 105*fem,
              decoration: BoxDecoration (
                color: Color(0xff25313c),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3f92b127),
                    offset: Offset(0*fem, 2*fem),
                    blurRadius: 5*fem,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // statusbariphone13miniorH (I124:825;117:198)
                    margin: EdgeInsets.fromLTRB(55*fem, 0*fem, 26.7*fem, 0*fem),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          // miccamvg1 (I124:825;117:215)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 75.3*fem, 9*fem),
                          width: 6*fem,
                          height: 6*fem,
                          child: Image.asset(
                            'assets/design/images/mic-cam-6QH.png',
                            width: 6*fem,
                            height: 6*fem,
                          ),
                        ),
                        Container(
                          // autogroupiso73Vj (NBxChRwt9HfP7sb9Pbiso7)
                          width: double.infinity,
                          height: 17*fem,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                // timezA5 (I124:825;117:216;1:394)
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 194*fem, 0*fem),
                                  child: Text(
                                    '09:41',
                                    textAlign: TextAlign.center,
                                    style: SafeGoogleFont (
                                      'SF Pro Text',
                                      fontSize: 17*ffem,
                                      fontWeight: FontWeight.w600,
                                      height: 1*ffem/fem,
                                      letterSpacing: -0.5*fem,
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // indicatorsGdP (I124:825;117:199)
                                margin: EdgeInsets.fromLTRB(0*fem, 2*fem, 0*fem, 2*fem),
                                height: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      // elementssignalodK (I124:825;117:200)
                                      margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 6*fem, 0*fem),
                                      width: 19.97*fem,
                                      height: 12*fem,
                                      child: Image.asset(
                                        'assets/design/images/elements-signal-wwP.png',
                                        width: 19.97*fem,
                                        height: 12*fem,
                                      ),
                                    ),
                                    Container(
                                      // elementsconnection7e1 (I124:825;117:206)
                                      margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 6*fem, 0*fem),
                                      width: 17*fem,
                                      height: 12.5*fem,
                                      child: Image.asset(
                                        'assets/design/images/elements-connection-ANm.png',
                                        width: 17*fem,
                                        height: 12.5*fem,
                                      ),
                                    ),
                                    Container(
                                      // elementsbatteryRPo (I124:825;117:211)
                                      width: 27.33*fem,
                                      height: 13*fem,
                                      child: Image.asset(
                                        'assets/design/images/elements-battery-moP.png',
                                        width: 27.33*fem,
                                        height: 13*fem,
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
                    // toparegularaflatMHT (I124:825;117:310)
                    padding: EdgeInsets.fromLTRB(16*fem, 11.5*fem, 20.88*fem, 11.5*fem),
                    width: double.infinity,
                    height: 56*fem,
                    decoration: BoxDecoration (
                      color: Color(0xff25313c),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // autogroup2h1tSZo (NBxCzvSjjerjia6fFs2h1T)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 168*fem, 0*fem),
                          height: double.infinity,
                          child: Center(
                            // logosbcfinal1nNm (I124:825;119:315)
                            child: SizedBox(
                              width: 83*fem,
                              height: 33*fem,
                              child: Image.asset(
                                'assets/design/images/logo-sbc-final-1-6ch.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          // trailingiconsVny (I124:825;117:313)
                          margin: EdgeInsets.fromLTRB(0*fem, 4.5*fem, 0*fem, 4.5*fem),
                          height: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // walletpqF (I124:825;119:201)
                                margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 15*fem, 0*fem),
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom (
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Container(
                                    width: 24*fem,
                                    height: 24*fem,
                                    child: Image.asset(
                                      'assets/design/images/wallet-LDP.png',
                                      width: 24*fem,
                                      height: 24*fem,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // trailingicon185F (I124:825;173:503)
                                margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 15*fem, 0*fem),
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom (
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Container(
                                    width: 24.12*fem,
                                    height: 24*fem,
                                    child: Image.asset(
                                      'assets/design/images/trailing-icon-1-QzD.png',
                                      width: 24.12*fem,
                                      height: 24*fem,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                // supervisedusercircleR4M (I124:825;119:260)
                                onPressed: () {},
                                style: TextButton.styleFrom (
                                  padding: EdgeInsets.zero,
                                ),
                                child: Container(
                                  width: 24*fem,
                                  height: 24*fem,
                                  child: Image.asset(
                                    'assets/design/images/supervisedusercircle-WCR.png',
                                    width: 24*fem,
                                    height: 24*fem,
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
              // frame121075647wHb (187:1213)
              margin: EdgeInsets.fromLTRB(24*fem, 0*fem, 25*fem, 6*fem),
              width: double.infinity,
              height: 639*fem,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // group45849rvM (187:1210)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 1*fem, 20*fem),
                    width: 340*fem,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // whatsyourphonenumberbN9 (187:1204)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 15*fem),
                          child: Text(
                            'Nos sortie passee ',
                            style: SafeGoogleFont (
                              'Montserrat',
                              fontSize: 16*ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.25*ffem/fem,
                              color: Color(0xfff49101),
                            ),
                          ),
                        ),
                        TextButton(
                          // divertissementcarouselHVs (185:1202)
                          onPressed: () {},
                          style: TextButton.styleFrom (
                            padding: EdgeInsets.zero,
                          ),
                          child: Container(
                            width: double.infinity,
                            child: Center(
                              // rectangle2771dpd (I185:1202;185:1192)
                              child: SizedBox(
                                width: 340*fem,
                                height: 240*fem,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24*fem),
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
                    // group458519ny (187:1212)
                    margin: EdgeInsets.fromLTRB(1*fem, 0*fem, 0*fem, 0*fem),
                    width: 340*fem,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // whatsyourphonenumber5wX (187:1205)
                          margin: EdgeInsets.fromLTRB(6*fem, 0*fem, 0*fem, 15*fem),
                          child: Text(
                            'En programme',
                            style: SafeGoogleFont (
                              'Montserrat',
                              fontSize: 16*ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.25*ffem/fem,
                              color: Color(0xfff49101),
                            ),
                          ),
                        ),
                        Container(
                          // group45850PxD (187:1211)
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // rectangle2771jmB (187:1206)
                                width: 340*fem,
                                height: 240*fem,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24*fem),
                                  child: Image.asset(
                                    'assets/design/images/rectangle-2771-cNm.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10*fem,
                              ),
                              Text(
                                // visitedewazaparkdrZ (187:1207)
                                'Visite de waza park',
                                style: SafeGoogleFont (
                                  'Montserrat',
                                  fontSize: 16*ffem,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25*ffem/fem,
                                  color: Color(0xff25313c),
                                ),
                              ),
                              SizedBox(
                                height: 10*fem,
                              ),
                              Container(
                                // frame1210756219pu (187:1208)
                                width: double.infinity,
                                height: 40*fem,
                                decoration: BoxDecoration (
                                  color: Color(0xff1862f0),
                                  borderRadius: BorderRadius.circular(66*fem),
                                ),
                                child: Center(
                                  child: Center(
                                    child: Text(
                                      'Reservez maintenant',
                                      textAlign: TextAlign.center,
                                      style: SafeGoogleFont (
                                        'Montserrat',
                                        fontSize: 15*ffem,
                                        fontWeight: FontWeight.w600,
                                        height: 1.6*ffem/fem,
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
              // materialyoubottomnavigationbar (124:1033)
              width: 391*fem,
              height: 94*fem,
              decoration: BoxDecoration (
                color: Color(0xfff1f5fb),
              ),
              child: Container(
                // tabstR7 (I124:1033;173:1799)
                width: double.infinity,
                height: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      // materialyoutab1qbF (I124:1033;173:1800)
                      onPressed: () {},
                      style: TextButton.styleFrom (
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(7.1*fem, 21*fem, 7.1*fem, 19*fem),
                        height: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // iconYkZ (I124:1033;173:1801)
                              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 6*fem),
                              width: 64*fem,
                              height: 32*fem,
                              child: Image.asset(
                                'assets/design/images/icon-DY5.png',
                                width: 64*fem,
                                height: 32*fem,
                              ),
                            ),
                            Container(
                              // label4yo (I124:1033;173:1803)
                              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 0*fem),
                              child: Text(
                                'Accueil',
                                textAlign: TextAlign.center,
                                style: SafeGoogleFont (
                                  'Montserrat',
                                  fontSize: 10*ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6*ffem/fem,
                                  letterSpacing: 0.400000006*fem,
                                  color: Color(0xff141b2c),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 0*fem,
                    ),
                    TextButton(
                      // materialyoutab4m7X (I124:1033;173:1804)
                      onPressed: () {},
                      style: TextButton.styleFrom (
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(19.1*fem, 28.96*fem, 19.1*fem, 21*fem),
                        height: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // shareplay5P7 (I124:1033;173:1805)
                              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0.01*fem, 12.27*fem),
                              width: 27.57*fem,
                              height: 15.77*fem,
                              child: Image.asset(
                                'assets/design/images/shareplay-Hww.png',
                                width: 27.57*fem,
                                height: 15.77*fem,
                              ),
                            ),
                            Text(
                              // labelzFB (I124:1033;173:1808)
                              'Publier',
                              textAlign: TextAlign.center,
                              style: SafeGoogleFont (
                                'Montserrat',
                                fontSize: 10*ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.6*ffem/fem,
                                letterSpacing: 0.400000006*fem,
                                color: Color(0xff444746),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 0*fem,
                    ),
                    Container(
                      // autogroupvkkr7Ko (NBxDDfaW9rzBVjj5W7VkkR)
                      width: 156.4*fem,
                      height: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            // materialyoutab2T8m (I124:1033;173:1809)
                            left: 0*fem,
                            top: 0*fem,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom (
                                padding: EdgeInsets.zero,
                              ),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(3.6*fem, 21*fem, 3.6*fem, 19*fem),
                                width: 78.2*fem,
                                height: 94*fem,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      // iconLTT (I124:1033;173:1810)
                                      margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 6*fem),
                                      width: 64*fem,
                                      height: 32*fem,
                                      child: Image.asset(
                                        'assets/design/images/icon-d9B.png',
                                        width: 64*fem,
                                        height: 32*fem,
                                      ),
                                    ),
                                    Text(
                                      // labeleyw (I124:1033;173:1812)
                                      'Market place',
                                      textAlign: TextAlign.center,
                                      style: SafeGoogleFont (
                                        'Montserrat',
                                        fontSize: 10*ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.6*ffem/fem,
                                        letterSpacing: 0.400000006*fem,
                                        color: Color(0xff444746),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            // materialyoutab3z2D (I124:1033;173:1813)
                            left: 78.1999511719*fem,
                            top: 0*fem,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0*fem, 17*fem, 0*fem, 15*fem),
                              width: 78.2*fem,
                              height: 94*fem,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    // iconUxy (I124:1033;173:1814)
                                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 6*fem),
                                    width: 104*fem,
                                    height: 40*fem,
                                    child: Image.asset(
                                      'assets/design/images/icon-Zvh.png',
                                      width: 104*fem,
                                      height: 40*fem,
                                    ),
                                  ),
                                  Text(
                                    // labelCe5 (I124:1033;173:1816)
                                    'Divertissement et tourisme',
                                    textAlign: TextAlign.center,
                                    style: SafeGoogleFont (
                                      'Montserrat',
                                      fontSize: 10*ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6*ffem/fem,
                                      letterSpacing: 0.400000006*fem,
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
                    SizedBox(
                      width: 0*fem,
                    ),
                    TextButton(
                      // materialyoutab5XgM (I124:1033;173:1817)
                      onPressed: () {},
                      style: TextButton.styleFrom (
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0*fem, 21*fem, 0*fem, 19*fem),
                        width: 78.2*fem,
                        height: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // iconEqf (I124:1033;173:1818)
                              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 6*fem),
                              width: 64*fem,
                              height: 32*fem,
                              child: Image.asset(
                                'assets/design/images/icon-JKb.png',
                                width: 64*fem,
                                height: 32*fem,
                              ),
                            ),
                            Text(
                              // labelZN9 (I124:1033;173:1820)
                              'Investissement',
                              textAlign: TextAlign.center,
                              style: SafeGoogleFont (
                                'Montserrat',
                                fontSize: 10*ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.6*ffem/fem,
                                letterSpacing: 0.400000006*fem,
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