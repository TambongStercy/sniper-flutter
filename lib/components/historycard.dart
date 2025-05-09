import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

// Helper function to format DateTime
String formatDateTime(DateTime dateTime) {
  // Example format: Feb 19, 2024 09:25 AM
  return DateFormat('MMM d, yyyy hh:mm a').format(dateTime);
}

class HistoryCard extends StatelessWidget {
  HistoryCard({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.dateTime,
    required this.deposit,
    this.pending,
    this.onTap,
  });

  final String transactionId;
  final int amount;
  final DateTime dateTime;
  final bool deposit;
  bool? pending;
  final Function(String transactionId)? onTap;

  @override
  Widget build(BuildContext context) {
    // double baseWidth = 390; // fem and ffem are not strictly necessary if we use fixed sizes or Theme-based sizes
    // double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    Color amountColor;
    String titleText;
    IconData iconData;

    if (pending == true) {
      amountColor = Color(0xfff59e0b); // Orange for pending
      titleText = context.translate('pending');
      iconData = Icons.hourglass_empty_rounded; // Icon for pending
    } else if (deposit) {
      amountColor = Colors.green; // Green for deposit
      titleText = context.translate('deposit');
      iconData = Icons.arrow_upward_rounded; // Icon for deposit
    } else {
      amountColor = Colors.red; // Red for withdrawal
      titleText = context.translate('withdrawal');
      iconData = Icons.arrow_downward_rounded; // Icon for withdrawal
    }

    String formattedDate =
        DateFormat('dd/MM/yyyy').format(dateTime); // Simplified date format

    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(transactionId);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 6.0), // Similar to TransactionRecord's outer padding
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0), // Similar to TransactionRecord's inner padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), // Consistent border radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(iconData, color: amountColor, size: 28), // Added Icon
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xff25313c), // Consistent text color
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate, // Use simplified date
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600], // Consistent subtitle color
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${deposit || pending == true ? "+" : "-"}${NumberFormat("#,##0", "fr_FR").format(amount)} FCFA', // Formatted amount with currency and sign
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold, // Bold amount
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
