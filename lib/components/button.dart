import 'package:flutter/material.dart';
import 'package:snipper_frontend/utils.dart';

class ReusableButton extends StatelessWidget {
  ReusableButton({
    super.key,
    required this.title,
    required this.onPress,
    this.mainColor,
    this.lite,
    this.clickable,
    this.cancel,
    this.mh,
  });

  final String title;
  final Function() onPress;
  final Function()? cancel;
  final Color? mainColor;
  final bool? lite;
  final bool? clickable;
  final double? mh;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    bool isClickable = clickable == null || clickable == true;

    Color color = isClickable
        ? (mainColor ?? orange)
        : Color.fromARGB(255, 153, 184, 242);
    Color white = const Color(0xffffffff);
    bool liteColor = lite ?? true;



    return Container(
      margin: EdgeInsets.fromLTRB((mh??30) * fem, 0 * fem, (mh??30) * fem, 13 * fem),
      child: TextButton(
        onPressed: isClickable ? onPress : cancel,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: double.infinity,
          height: 44 * fem,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            color: liteColor == false ? color : white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 14 * ffem,
                  fontWeight: FontWeight.w500,
                  height: 1.7142857143 * ffem / fem,
                  color: liteColor == false ? white : color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
