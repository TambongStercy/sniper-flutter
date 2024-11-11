import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/carousel.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/main.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension

class Scene extends StatelessWidget {
  
  final String? affiliationCode;

  const Scene({Key? key, this.affiliationCode}) : super(key: key);

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
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 0 * fem, 34 * fem),
                    width: 300 * fem,
                    height: 300 * fem,
                    child: Image.asset(
                      image,
                      width: 300 * fem,
                      height: 208 * fem,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(24 * fem, 0 * fem, 0 * fem, 0 * fem),
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
        context.translate('networking'),
        context.translate('networking_description'),
      ),
      silde(
        'assets/design/images/undrawsharelinkre54rx-1.png',
        context.translate('advertising'),
        context.translate('advertising_description'),
      ),
      silde(
        'assets/design/images/undrawjoinrew1lh.png',
        context.translate('business_p2p'),
        context.translate('business_p2p_description'),
      ),
      silde(
        'assets/design/images/auto-group-e42u.png',
        context.translate('investment'),
        context.translate('investment_description'),
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding:
                  EdgeInsets.fromLTRB(0 * fem, 20 * fem, 0 * fem, 88 * fem),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Row(
                          children: [
                            Icon(Icons.language),
                            Text(
                              Localizations.localeOf(context)
                                  .languageCode
                                  .toUpperCase(),
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 14 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.7142857143 * ffem / fem,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          // Toggle between English and French
                          Locale newLocale =
                              Localizations.localeOf(context).languageCode == 'en'
                                  ? Locale('fr')
                                  : Locale('en');
                          MyApp.setLocale(context, newLocale);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  CustomCarousel(
                    slides: slides,
                  ),
                  ReusableButton(
                    title: context.translate('login'),
                    onPress: () {
                      context.pushNamed(Connexion.id);
                    },
                  ),
                  ReusableButton(
                    title: context.translate('create_account'),
                    onPress: () {
                      context.pushNamed(
                        Inscription.id,
                        queryParameters: {'affiliationCode': affiliationCode},
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
