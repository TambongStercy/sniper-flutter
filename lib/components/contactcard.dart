import 'package:flutter/material.dart';
import 'package:snipper_frontend/utils.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.date,
    required this.onPress,
  });

  final String date;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;


    return Container(
      padding: EdgeInsets.fromLTRB(30 * fem, 9 * fem, 30 * fem, 9 * fem),
      width: double.infinity,
      height: 65 * fem,
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(13 * fem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // frame1210756567nR (303:849)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // fichedecontactsbceGZ (303:850)
                  'Fiche de contact SBC',
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 14 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1.4285714286 * ffem / fem,
                    color: Color(0xff25313c),
                  ),
                ),
                Text(
                  date,
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 10 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 2 * ffem / fem,
                    color: Color(0xff6d7d8b),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // pictureaspdfJ6D (303:852)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 1 * fem),
            width: 20.83 * fem,
            height: 20.83 * fem,
            child: Icon(
              Icons.picture_as_pdf_outlined,
              size: 20.83 * fem,
              color: Color(0xff6d7d8b),
            ),
          ),
        ],
      ),
    );
  }
}
