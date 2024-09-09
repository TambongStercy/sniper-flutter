import 'package:flutter/material.dart';
import 'package:snipper_frontend/utils.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    super.key,
    required this.title,
    required this.iconImage,
    required this.onPress,
  });

  final String title;
  final Widget iconImage;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return TextButton(
      onPressed: onPress,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20 * fem,
          11 * fem,
          19.69 * fem,
          10 * fem,
        ),
        width: double.infinity,
        height: 71 * fem,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(10.0), // Optional: Add border radius
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // You can set the shadow color as needed
              spreadRadius: 1,
              offset: Offset(
                0,
                1,
              ), // Changes the position of the shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            iconImage,
            Expanded(
              child: Text(
               title,
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 13 * ffem,
                  fontWeight: FontWeight.w400,
                  height: 1.3846153846 * ffem / fem,
                  color: Color(0xff6d7d8b),
                ),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.fromLTRB(2 * fem, 0 * fem, 0 * fem, 0.99 * fem),
              width: 16.23 * fem,
              height: 16.24 * fem,
              child: Image.asset(
                'assets/design/images/chevrondowncirclefill-4H7.png',
                width: 16.23 * fem,
                height: 16.24 * fem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
