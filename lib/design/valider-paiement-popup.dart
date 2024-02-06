import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'dart:ui';
// import 'package:google_fonts/google_fonts.dart';
import 'package:snipper_frontend/utils.dart';

class Scene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 322;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      width: double.infinity,
      child: Container(
        width: double.infinity,
        height: 54*fem,
        decoration: BoxDecoration (
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(14*fem),
        ),
        child: Center(
          child: Center(
            child: Text(
              'Demande de retrait confirmer',
              textAlign: TextAlign.center,
              style: SafeGoogleFont (
                'Montserrat',
                fontSize: 16*ffem,
                fontWeight: FontWeight.w700,
                height: 1.5*ffem/fem,
                color: Color(0xff25313c),
              ),
            ),
          ),
        ),
      ),
          );
  }
}