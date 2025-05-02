import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snipper_frontend/utils.dart'; // For SafeGoogleFont if needed
import 'package:snipper_frontend/localization_extension.dart'; // For context.translate

class TransactionDetailModal extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailModal({Key? key, required this.transaction})
      : super(key: key);

  // Helper to format date/time nicely
  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      // Example Format: May 1, 2024 - 02:30 PM
      return DateFormat('MMM d, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      print("Error parsing date in modal: $e");
      return dateString; // Return original string if parsing fails
    }
  }

  // Helper to get status color
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper to capitalize string
  String _capitalize(String? s) =>
      s == null || s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    // Extract data safely
    final String type = transaction['type']?.toString() ?? 'N/A';
    final String status = transaction['status']?.toString() ?? 'N/A';
    final double amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final String currency = transaction['currency']?.toString() ?? 'XAF';
    final String createdAt = transaction['createdAt']?.toString() ?? '';
    final String updatedAt = transaction['updatedAt']?.toString() ?? '';
    final String description = transaction['description']?.toString() ?? '';
    final String transactionId = transaction['transactionId']?.toString() ?? '';
    final String internalId = transaction['_id']?.toString() ?? '';

    return Container(
      // Make it look like a bottom sheet
      padding: EdgeInsets.all(20 * fem),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * fem),
          topRight: Radius.circular(20 * fem),
        ),
      ),
      child: Wrap(
        // Use Wrap to fit content
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Take minimum space
            children: [
              // Title
              Center(
                child: Text(
                  context.translate('transaction_details'),
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 18 * ffem,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 15 * fem),
              Divider(),
              SizedBox(height: 15 * fem),

              // Details using helper widget
              _buildDetailRow(
                  context, ffem, fem, context.translate('id'), transactionId),
              _buildDetailRow(context, ffem, fem, context.translate('type'),
                  _capitalize(type)),
              _buildDetailRow(
                context,
                ffem,
                fem,
                context.translate('status'),
                Text(
                  _capitalize(status),
                  style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w500),
                ),
              ),
              _buildDetailRow(context, ffem, fem, context.translate('amount'),
                  '${amount.toStringAsFixed(0)} $currency'),
              _buildDetailRow(context, ffem, fem,
                  context.translate('description'), description,
                  isMultiline: true),
              _buildDetailRow(context, ffem, fem,
                  context.translate('created_at'), _formatDateTime(createdAt)),
              _buildDetailRow(
                  context,
                  ffem,
                  fem,
                  context.translate('last_updated'),
                  _formatDateTime(updatedAt)),
              // You can uncomment this if needed, but transactionId is usually more relevant
              // _buildDetailRow(context, ffem, fem, 'Internal ID', internalId),

              SizedBox(height: 20 * fem),
              // Close Button
              Center(
                child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.translate('close')),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30 * fem, vertical: 10 * fem),
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                    )),
              ),
              SizedBox(height: 10 * fem), // Space at bottom
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for consistent detail rows
  Widget _buildDetailRow(BuildContext context, double ffem, double fem,
      String label, dynamic value,
      {bool isMultiline = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * fem),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100 * fem, // Fixed width for labels
            child: Text(
              label,
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 13 * ffem,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(width: 10 * fem),
          Expanded(
            child: value is Widget
                ? value
                : Text(
                    value?.toString() ?? 'N/A',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 13 * ffem,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
