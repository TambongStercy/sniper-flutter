
import 'package:flutter/material.dart';

class Scene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom (
          padding: EdgeInsets.zero,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(74*fem, 373*fem, 75*fem, 374*fem),
          width: double.infinity,
          height: 844*fem,
          decoration: BoxDecoration (
            color: Color(0xffffffff),
          ),
          child: Center(
            child: SizedBox(
              width: 241*fem,
              height: 97*fem,
              child: Image.asset(
                'assets/design/images/logo-sbc-final-2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
          );
  }
}