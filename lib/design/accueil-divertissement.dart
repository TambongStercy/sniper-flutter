import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/imagecard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/theme.dart';

class Divertissement extends StatelessWidget {
  const Divertissement({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16 * fem, 24 * fem, 16 * fem, 24 * fem),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Padding(
              padding: EdgeInsets.only(bottom: 16 * fem),
              child: Text(
                context.translate('past_outings'),
                style: TextStyle(
                  fontSize: 20 * ffem,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),

            // Past outings card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              margin: EdgeInsets.only(bottom: 24 * fem),
              child: Padding(
                padding: EdgeInsets.all(16 * fem),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12 * fem),
                      child: Image.asset(
                        'assets/design/images/rectangle-2771-54d.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming section title
            Padding(
              padding: EdgeInsets.only(bottom: 16 * fem, top: 8 * fem),
              child: Text(
                context.translate('upcoming'),
                style: TextStyle(
                  fontSize: 20 * ffem,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),

            // Upcoming events card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              margin: EdgeInsets.only(bottom: 24 * fem),
              child: Padding(
                padding: EdgeInsets.all(16 * fem),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12 * fem),
                      child: Image.asset(
                        'assets/design/images/rectangle-2771-cNm.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16 * fem),
                    Text(
                      context.translate('waza_park_visit'),
                      style: TextStyle(
                        fontSize: 18 * ffem,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16 * fem),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16 * fem),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.translate('book_now'),
                          style: TextStyle(
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
