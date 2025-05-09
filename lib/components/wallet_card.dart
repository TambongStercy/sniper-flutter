import 'package:flutter/material.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/localization_extension.dart';

class WalletCard extends StatelessWidget {
  final double balance;
  final VoidCallback onDepositPressed;
  final VoidCallback onWithdrawPressed;
  final VoidCallback onTransferPressed;
  final String? currencySymbol;

  const WalletCard({
    Key? key,
    required this.balance,
    required this.onDepositPressed,
    required this.onWithdrawPressed,
    required this.onTransferPressed,
    this.currencySymbol = 'FCFA',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 212,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppTheme.walletGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          left: 24.0,
          right: 24.0,
          bottom: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('total_balance'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${balance.toStringAsFixed(2)} $currencySymbol',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.add,
                  label: context.translate('deposit'),
                  onPressed: onDepositPressed,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.arrow_downward,
                  label: context.translate('withdraw'),
                  onPressed: onWithdrawPressed,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.swap_horiz,
                  label: context.translate('transfer'),
                  onPressed: onTransferPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
