import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RatingTag extends StatelessWidget {
  final double value;
  final EdgeInsetsGeometry margin;
  final int length;
  RatingTag({required this.value, required this.margin, required this.length});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 50,
      margin: margin,
      padding: EdgeInsets.only(top: 4, bottom: 4, left: 5, right: 8),
      decoration: BoxDecoration(
          color: Colors.black54, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/Star-active.svg',
            width: 14,
            height: 14,
          ),
          SizedBox(width: 4),
          Text(
            '$value ($length)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
