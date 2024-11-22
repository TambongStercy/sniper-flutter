import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/historycard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Assuming you have this for context.translate

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
        color: const Color(0xffffffff),
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
                margin: EdgeInsets.only(bottom: 15 * fem),
                child: Text(
                  context.translate('transaction_history'),
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 20 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1 * ffem / fem,
                    color: const Color(0xff25313c),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: transactions.map((trans) {
                  final date = formatTime(trans['date']);  // Formatting date safely
                  final isDeposit = trans['transType'] == 'deposit';
                  final amount = trans['amount'] != null
                      ? int.tryParse(trans['amount'].toString()) ?? 0  // Safely parsing amount
                      : 0;
                      
                  return HistoryCard(
                    time: date,
                    deposit: isDeposit,
                    amount: amount,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
