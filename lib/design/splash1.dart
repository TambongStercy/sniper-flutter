import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snipper_frontend/components/carousel.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/main.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/localization_extension.dart';

class Scene extends StatelessWidget {
  static const id = 'splash1';
  final String? affiliationCode;

  const Scene({Key? key, this.affiliationCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Define the slides for the carousel
    Widget buildSlide(String image, String title, String subtitle) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 280,
              height: 280,
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
                maxWidth: 280,
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
        ),
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
      body: Stack(
        children: [
          // Background gradient - using mint green colors like in the image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD4F1D4), // Light mint green
                    Color(0xFFE8F8E8), // Very light mint green
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar with logo and language selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SBC Logo at top left
                      Image.asset(
                        'assets/assets/images/logo-sbc-final-1-14d.png',
                        height: 40,
                      ),

                      // Language selector styled like in the image (pill-shaped)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          icon: const Icon(Icons.language, size: 18),
                          label: Text(
                            Localizations.localeOf(context)
                                .languageCode
                                .toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          onPressed: () {
                            // Toggle between English and French
                            Locale newLocale =
                                Localizations.localeOf(context).languageCode ==
                                        'en'
                                    ? const Locale('fr')
                                    : const Locale('en');
                            MyApp.setLocale(context, newLocale);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content - carousel in a card-like container
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: CustomCarousel(
                      slides: slides,
                    ),
                  ),
                ),

                // Buttons at the bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pushNamed(
                              Connexion.id,
                              queryParameters: affiliationCode != null
                                  ? {'affiliationCode': affiliationCode!}
                                  : {},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              context.translate('login'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.pushNamed(
                              Inscription.id,
                              queryParameters: affiliationCode != null
                                  ? {'affiliationCode': affiliationCode!}
                                  : {},
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              context.translate('create_account'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
