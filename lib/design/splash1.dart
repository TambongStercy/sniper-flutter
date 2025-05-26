import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snipper_frontend/components/carousel.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/main.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/components/button.dart';

class Scene extends StatelessWidget {
  static const id = 'splash1';
  final String? affiliationCode;

  const Scene({Key? key, this.affiliationCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    Widget buildSlide(String image, String title, String subtitle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            width: 300,
            height: 300,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.tertiaryOrange,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ],
      );
    }

    List<Widget> slides = [
      buildSlide(
        'assets/assets/images/SBA.jpg',
        context.translate('networking'),
        context.translate('networking_description'),
      ),
      buildSlide(
        'assets/design/images/undrawsharelinkre54rx-1.png',
        context.translate('advertising'),
        context.translate('advertising_description'),
      ),
      buildSlide(
        'assets/design/images/undrawjoinrew1lh.png',
        context.translate('business_p2p'),
        context.translate('business_p2p_description'),
      ),
      buildSlide(
        'assets/design/images/auto-group-e42u.png',
        context.translate('investment'),
        context.translate('investment_description'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenSize.height,
          child: Container(
            color: Color(0xFFE0F2E9),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/design/images/logo-sbc-final-1-AdP.png',
                          height: 40,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: TextButton.icon(
                            icon: Icon(Icons.language,
                                color: Colors.black87, size: 20),
                            label: Text(
                              Localizations.localeOf(context)
                                  .languageCode
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            onPressed: () {
                              Locale newLocale = Localizations.localeOf(context)
                                          .languageCode ==
                                      'en'
                                  ? const Locale('fr')
                                  : const Locale('en');
                              MyApp.setLocale(context, newLocale);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomCarousel(
                    slides: slides,
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: ReusableButton(
                      title: context.translate('login'),
                      mh: 0,
                      onPress: () {
                        context.pushNamed(
                          Connexion.id,
                          queryParameters: affiliationCode != null
                              ? {'affiliationCode': affiliationCode!}
                              : {},
                        );
                      },
                      lite: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: ReusableButton(
                      title: context.translate('create_account'),
                      mh: 0,
                      onPress: () {
                        context.pushNamed(
                          Inscription.id,
                          queryParameters: affiliationCode != null
                              ? {'affiliationCode': affiliationCode!}
                              : {},
                        );
                      },
                      lite: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
