import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/historycard.dart';
import 'package:snipper_frontend/utils.dart';

class BottomHitory extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const BottomHitory({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25 * fem),
          topRight: Radius.circular(25 * fem),
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(25 * fem, 20 * fem, 25 * fem, 24 * fem),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin:
                    EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
                child: Text(
                  'Historique transactions',
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 20 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1 * ffem / fem,
                    color: Color(0xff25313c),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: transactions.map((trans) {
                  final date = formatTime(trans['date']);
                  final type = trans['transType'] == 'deposit';
                  final amt = trans['amount'];
                  return HistoryCard(
                    time: date,
                    deposit: type,
                    amount: int.parse(amt),
                  );
                }).toList(),
                // [
                //  Text(
                //    '02/01/24',
                //    style: SafeGoogleFont(
                //      'Montserrat',
                //      fontSize: 14 * ffem,
                //      fontWeight: FontWeight.w500,
                //      height: 1.4285714286 * ffem / fem,
                //      color: Color(0xfff49101),
                //    ),
                //  ),
                //   HistoryCard(
                //     time: '12:25 pm',
                //     deposit: true,
                //     amount: amt,
                //   ),
                //   HistoryCard(
                //     time: '10:25 pm',
                //     deposit: true,
                //     amount: 5525,
                //   ),
                //   Text(
                //     '30/12/23',
                //     style: SafeGoogleFont(
                //       'Montserrat',
                //       fontSize: 14 * ffem,
                //       fontWeight: FontWeight.w500,
                //       height: 1.4285714286 * ffem / fem,
                //       color: Color(0xfff49101),
                //     ),
                //   ),
                //   HistoryCard(
                //     time: '12:25 pm',
                //     deposit: false,
                //     amount: 3525,
                //   ),
                //   HistoryCard(
                //     time: '10:25 pm',
                //     deposit: false,
                //     amount: 5525,
                //   ),
                //   HistoryCard(
                //     time: '12:25 pm',
                //     deposit: true,
                //     amount: 3525,
                //   ),
                //   HistoryCard(
                //     time: '10:25 pm',
                //     deposit: true,
                //     amount: 5525,
                //   ),
                // ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
