import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';

class AdCard extends StatelessWidget {
  const AdCard({
    super.key,
    required this.buttonTitle,
    required this.buttonAction,
    required this.child,
    this.height = 250,
  });

  final String buttonTitle;
  final Function() buttonAction;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    return Container(
      // autogroupm7rjHbw (NBwmfpKJXseGejF4JnM7Rj)
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 26 * fem),
      padding: EdgeInsets.fromLTRB(7 * fem, 10 * fem, 7 * fem, 10 * fem),
      width: 354 * fem,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffbbc8d4)),
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(15 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 10 * fem),
            height: height * fem,
            child: child,
          ),
          ReusableButton(
            title: buttonTitle,
            lite: false,
            onPress: buttonAction,
          ),
        ],
      ),
    );
  }
}
