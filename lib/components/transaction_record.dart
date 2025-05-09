import 'package:flutter/material.dart';
import 'package:snipper_frontend/theme.dart';

class TransactionRecord extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final bool isDeposit;
  final VoidCallback onTap;
  final String? currencySymbol;

  const TransactionRecord({
    Key? key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isDeposit,
    required this.onTap,
    this.currencySymbol = 'FCFA',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Transaction icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDeposit
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isDeposit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Transaction amount
            Text(
              '${isDeposit ? '+' : '-'}${amount.toStringAsFixed(2)} $currencySymbol',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDeposit ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
