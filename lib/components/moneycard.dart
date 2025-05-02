import 'package:flutter/material.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

// ignore: must_be_immutable
class MoneyCard extends StatelessWidget {
  MoneyCard({
    super.key,
    this.isSold,
    required this.amount,
  });

  bool? isSold;
  double amount;

  @override
  Widget build(BuildContext context) {
    final isRSold = isSold ?? false;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define colors based on theme and type (sold/benefit)
    final Color primaryColor =
        isRSold ? colorScheme.primary : colorScheme.secondary;
    final Color onPrimaryColor =
        isRSold ? colorScheme.onPrimary : colorScheme.onSecondary;
    final Color iconBackgroundColor =
        primaryColor.withOpacity(0.15); // Subtle background for icon

    final icon = isRSold
        ? Icons.account_balance_wallet_rounded
        : Icons.keyboard_double_arrow_up_rounded;
    final text = isRSold
        ? context.translate('sold_current')
        : context.translate('total_profit');

    return Container(
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 0),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor, // Use primary/secondary for background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Position the icon on the right, vertically centered
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 5.0,
              ), // Add some padding from the edge
              child: Icon(
                icon,
                size: 60,
                // Use the theme's onPrimary/onSecondary color with opacity
                color: onPrimaryColor.withOpacity(0.16),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: onPrimaryColor, // Use onPrimary/onSecondary for text
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '${amount.toStringAsFixed(1)} FCFA',
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                  color: onPrimaryColor, // Use onPrimary/onSecondary for text
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
