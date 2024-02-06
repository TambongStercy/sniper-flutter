import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
import 'dart:ui';
// import 'package:google_fonts/google_fonts.dart';
import 'package:snipper_frontend/utils.dart';

class Scene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 374;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      width: double.infinity,
      child: Container(
        // snipervideooverlayCFT (12:597)
        padding: EdgeInsets.fromLTRB(36*fem, 16*fem, 28*fem, 54*fem),
        width: double.infinity,
        decoration: BoxDecoration (
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(12*fem),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              // closeVVT (12:629)
              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 33*fem),
              width: 30*fem,
              height: 30*fem,
              child: Image.asset(
                'assets/design/images/close.png',
                width: 30*fem,
                height: 30*fem,
              ),
            ),
            Container(
              // group45802c4H (12:602)
              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 8.54*fem, 40*fem),
              padding: EdgeInsets.fromLTRB(129*fem, 85*fem, 124.46*fem, 86*fem),
              decoration: BoxDecoration (
                borderRadius: BorderRadius.circular(24*fem),
                color: Color(0x26000000),
                image: DecorationImage (
                  fit: BoxFit.cover,
                  image: AssetImage (
                    'assets/design/images/rectangle-2772-bg.png',
                  ),
                ),
              ),
              child: Center(
                // polygon2GuX (12:605)
                child: SizedBox(
                  width: 48*fem,
                  height: 48*fem,
                  child: Image.asset(
                    'assets/design/images/polygon-2-PrH.png',
                    width: 48*fem,
                    height: 48*fem,
                  ),
                ),
              ),
            ),
            Container(
              // frame121075619nss (12:606)
              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 15.27*fem, 0*fem),
              width: 292*fem,
              height: 30*fem,
              decoration: BoxDecoration (
                color: Color(0xff1862f0),
                borderRadius: BorderRadius.circular(66*fem),
              ),
              child: Center(
                child: Center(
                  child: Text(
                    'Telecharger le document',
                    textAlign: TextAlign.center,
                    style: SafeGoogleFont (
                      'Montserrat',
                      fontSize: 12*ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.3333333333*ffem/fem,
                      letterSpacing: 0.400000006*fem,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          );
  }
}