import 'package:flutter/material.dart';
import 'package:snipper_frontend/theme.dart';

class ModernTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool showIndicator;
  final double height;

  const ModernTabs({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.showIndicator = true,
    this.height = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: _buildTab(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              tabs[index],
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            // if (isSelected && showIndicator)
            //   Positioned(
            //     bottom: 0,
            //     child: Container(
            //       height: 2,
            //       width: 24,
            //       decoration: BoxDecoration(
            //         color: AppTheme.primaryBlue,
            //         borderRadius: BorderRadius.circular(2),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
