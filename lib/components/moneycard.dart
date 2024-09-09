import 'package:flutter/material.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';

// ignore: must_be_immutable
class MoneyCard extends StatelessWidget {
  MoneyCard({
    super.key,
    this.isSold,
    required this.amount
  });

  bool? isSold;
  double amount;

  @override
  Widget build(BuildContext context) {

    final isRSold = isSold??false;

    final color = isRSold ? blue : limeGreen;
    final icon = isRSold ? Icons.account_balance_wallet_rounded : Icons.keyboard_double_arrow_up_rounded;
    final text = isRSold ? 'Sold current' :'Benefice total';

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              icon,
              size: 72,
              color:
                  Colors.white.withOpacity(0.2), // Transparent background icon
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                text,
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '${amount.toStringAsFixed(1)}FCFA',
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                  color: Colors.white,
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
