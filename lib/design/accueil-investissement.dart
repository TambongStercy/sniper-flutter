import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/imagecard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/theme.dart';

class Investissement extends StatelessWidget {
  const Investissement({super.key});

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
            // Title
            Padding(
              padding: EdgeInsets.only(bottom: 16 * fem),
              child: Text(
                context.translate('investment_opportunities'),
                style: TextStyle(
                  fontSize: 20 * ffem,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),

            // Investment opportunity card
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
                        'assets/design/images/rectangle-2771-x9F.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16 * fem),
                    Text(
                      context.translate('available_shares'),
                      style: TextStyle(
                        fontSize: 18 * ffem,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tertiaryOrange,
                      ),
                    ),
                    SizedBox(height: 12 * fem),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.translate('progress'),
                          style: TextStyle(
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '500/500',
                          style: TextStyle(
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * fem),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 1,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.secondaryGreen,
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
