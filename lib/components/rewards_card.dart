import 'package:flutter/material.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/localization_extension.dart';

class RewardsCard extends StatelessWidget {
  final double rewardsBalance;
  final VoidCallback onViewDetailsPressed;
  final String? currencySymbol;

  const RewardsCard({
    Key? key,
    required this.rewardsBalance,
    required this.onViewDetailsPressed,
    this.currencySymbol = 'FCFA',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Text(
          //       context.translate('rewards_balance'),
          //       style: TextStyle(
          //         color: Colors.grey[700],
          //         fontSize: 16,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     TextButton(
          //       onPressed: onViewDetailsPressed,
          //       child: Text(
          //         context.translate('view_details'),
          //         style: TextStyle(
          //           color: AppTheme.primaryBlue,
          //           fontSize: 14,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          
          Text(
            context.translate('rewards_balance'),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${rewardsBalance.toStringAsFixed(2)} $currencySymbol',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
