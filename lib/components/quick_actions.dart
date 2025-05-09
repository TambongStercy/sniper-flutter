import 'package:flutter/material.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/localization_extension.dart';

class QuickActions extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActions({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            context.translate('quick_actions'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                actions.map((action) => _buildActionItem(action)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(QuickActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: action.backgroundColor.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: action.backgroundColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              action.icon,
              color: action.backgroundColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            action.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  QuickActionItem({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  // Factory methods for common actions
  factory QuickActionItem.mobileMoney(
      {required VoidCallback onTap, required String label}) {
    return QuickActionItem(
      icon: Icons.phone_android,
      label: label,
      backgroundColor: AppTheme.primaryBlue,
      onTap: onTap,
    );
  }

  factory QuickActionItem.bankTransfer(
      {required VoidCallback onTap, required String label}) {
    return QuickActionItem(
      icon: Icons.account_balance,
      label: label,
      backgroundColor: AppTheme.secondaryGreen,
      onTap: onTap,
    );
  }

  factory QuickActionItem.billPayment(
      {required VoidCallback onTap, required String label}) {
    return QuickActionItem(
      icon: Icons.receipt_long,
      label: label,
      backgroundColor: AppTheme.tertiaryOrange,
      onTap: onTap,
    );
  }

  factory QuickActionItem.more(
      {required VoidCallback onTap, required String label}) {
    return QuickActionItem(
      icon: Icons.more_horiz,
      label: label,
      backgroundColor: Colors.grey.shade700,
      onTap: onTap,
    );
  }
}
