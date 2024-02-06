import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/imagecard.dart';
import 'package:snipper_frontend/utils.dart';

class Investissement extends StatelessWidget {
  const Investissement({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
      padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ImageCard(
            image: 'assets/design/images/rectangle-2771-x9F.png',
          ),
          Text(
            'Nombre d’action disponible',
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w500,
              height: 1.25 * ffem / fem,
              color: Color(0xfff49101),
            ),
          ),
          SizedBox(height: 10.0),
          Align(
            child: Text(
              '500/500',
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 12 * ffem,
                fontWeight: FontWeight.w500,
              ),
            ),
            alignment: Alignment.centerRight,
          ),
          LinearProgressIndicator(
            value: 1,
            color: Color(0xff92b127),
            borderRadius: BorderRadius.circular(15),
          ),
       
        ],
      ),
    );
  }
}
