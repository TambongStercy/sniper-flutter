import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/carousel.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'dart:ui';
// import 'package:google_fonts/google_fonts.dart';
import 'package:snipper_frontend/utils.dart';

class Scene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    Widget silde(image, title, subtitle) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 11 * fem, 19 * fem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 34 * fem),
                    width: 300 * fem,
                    height: 300 * fem,
                    child: Image.asset(
                      image,
                      width: 300 * fem,
                      height: 208 * fem,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(24 * fem, 0 * fem, 0 * fem, 0 * fem),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 20 * ffem,
                        fontWeight: FontWeight.w800,
                        height: 1 * ffem / fem,
                        color: Color(0xfff49101),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 5 * fem),
              constraints: BoxConstraints(
                maxWidth: 300 * fem,
              ),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 13 * ffem,
                  fontWeight: FontWeight.w400,
                  height: 1.4 * ffem / fem,
                  color: Color(0xff7e7e7e),
                ),
              ),
            ),
          ],
        ),
      );
    }

    List<Widget> slides = [
      silde(
        'assets/assets/images/SBA.jpg',
        'Réseautage',
        'Bienvenue sur Sniper Business Center, votre porte d\'entrée vers un réseau professionnel florissant au Cameroun. Connectez-vous, élargissez votre cercle d\'influence et explorez des opportunités de partenariat.',
      ),
      silde(
        'assets/design/images/undrawsharelinkre54rx-1.png',
        'Publicité',
        'Faites briller votre entreprise avec Sniper Business Center ! Boostez votre visibilité grâce à des outils publicitaires ciblés. Mettez en avant vos produits et services pour atteindre votre public idéal.    ',
      ),
      silde(
        'assets/design/images/undrawjoinrew1lh.png',
        ' Business P2P',
        'Explorez de nouvelles opportunités de commerce direct avec Sniper Business Center. Simplifiez les transactions entre pairs, favorisant des échanges rapides et transparents.',
      ),
      silde(
        'assets/design/images/auto-group-e42u.png',
        'Investissement',
        'Façonnez l\'avenir de vos affaires avec Sniper Business Center. Découvrez des opportunités d\'investissement passionnantes et explorez des projets en plein essor.',
      ),
        // 'assets/design/images/auto-group-1usk.png',
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding:
                  EdgeInsets.fromLTRB(0 * fem, 35 * fem, 0 * fem, 88 * fem),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomCarousel(
                    slides: slides,
                  ),
                  ReusableButton(
                    title: 'Se connecter',
                    onPress: () {
                      Navigator.pushNamed(
                        context,
                        Connexion.id,
                      );
                    },
                  ),
                  ReusableButton(
                    title: 'Creer un compte',
                    onPress: () {
                      Navigator.pushNamed(
                        context,
                        Inscription.id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
