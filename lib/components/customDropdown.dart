import 'package:flutter/material.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';

class HistoryDropdown extends StatelessWidget {
  const HistoryDropdown({
    super.key,
    required this.title,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final Color color;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: Color(0x3f25313c),
              blurRadius: 2.9,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.translate('history'),
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.8,
                color: Color(0xfff49101),
              ),
            ),
            CircleAvatar(
              radius: 13,
              backgroundColor: color,
              child: Icon(
                Icons.expand_more,
                color: Color(0xffffffff),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
