import 'package:flutter/material.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

class HistoryCard extends StatelessWidget {
  HistoryCard({
    super.key,
    required this.amount,
    required this.time,
    required this.deposit,
    this.pending,
  });

  final int amount;
  final String time;
  final bool deposit;
  bool? pending;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    Color color;
    String action;

    if (deposit) {
      color = Color(0xff00bf4c);
      action = context.translate('deposit_action');
    } else {
      color = Color(0xffed445d);
      action = context.translate('withdraw_action');
    } 

    if(pending != null && pending == true){
      color = Color(0xfff59e0b);
      action = context.translate('pending');
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24 * fem, 9 * fem, 24 * fem, 9 * fem),
      margin: EdgeInsets.symmetric(vertical: 10 * fem),
      width: double.infinity,
      height: 63 * fem,
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(13 * fem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(
              0 * fem,
              0 * fem,
              0 * fem,
              0 * fem,
            ),
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${action} ${context.translate('money')}',
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 14 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1.4285714286 * ffem / fem,
                    color: Color(0xff25313c),
                  ),
                ),
                Text(
                  time,
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 10 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 2 * ffem / fem,
                    color: Color(0xff6d7d8b),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amount XFA',
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 14 * ffem,
              fontWeight: FontWeight.w500,
              height: 1.4285714286 * ffem / fem,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
