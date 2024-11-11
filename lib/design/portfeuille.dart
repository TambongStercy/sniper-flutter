import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/historique-transaction-bottom-sheet.dart';
import 'package:snipper_frontend/design/retrait.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization

class Wallet extends StatefulWidget {
  static const id = 'wallet';

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  double balance = 0;
  double benefice = 0;
  String email = '';
  bool showSpinner = true;
  List<Map<String, dynamic>> transactions = [];
  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    balance = prefs.getDouble('balance') ?? 0;
    email = prefs.getString('email') ?? '';
    transactions = await getTransactions();
    benefice = getTransactionsBenefit(prefs);
  }

  @override
  void initState() {
    super.initState();

    // Create anonymous function:
    () async {
      try {
        await getInfos();

        showSpinner = false;
        refreshPage();
      } catch (e) {
        print(e);

        showSpinner = false;
        refreshPage();
      }
    }();
  }

  refreshPage() {
    if (mounted) {
      initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }
  }

  Future<void>? getInfos() async {
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final token = prefs.getString('token');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$getUpdates?email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'];
      error = jsonResponse['error'];

      if (response.statusCode == 200) {
        final user = jsonResponse['user'];

        final region = user['region'];
        email = user['email'] ?? '';
        final phone = user['phoneNumber'].toString();
        final userCode = user['code'];
        balance = user['balance'].toDouble();
        final name = user['name'] ?? '';
        final isSubscribed = user['isSubscribed'] ?? false;
        final gottenTransactions = user['transactions'] ?? [];
        prefs.setString('name', name);
        prefs.setString('email', email);
        prefs.setString('region', region);
        prefs.setString('phone', phone);
        prefs.setString('code', userCode);
        prefs.setDouble('balance', balance);
        prefs.setBool('isSubscribed', isSubscribed);
        await saveTransactionList(gottenTransactions);
        transactions = await getTransactions();

        setState(() {});

        print('all good');
      } else {
        if (error == 'Accès refusé') {
          String title = context.translate('error_access_denied');
          showPopupMessage(context, title, msg);

          if (!kIsWeb) {
            final avatar = prefs.getString('avatar') ?? '';

            await deleteFile(avatar);
            // await unInitializeOneSignal();
          }

          prefs.setString('token', '');
          prefs.setString('id', '');
          prefs.setString('email', '');
          prefs.setString('name', '');
          prefs.setString('token', '');
          prefs.setString('region', '');
          prefs.setString('phone', '');
          prefs.setString('code', '');
          prefs.setString('avatar', '');
          prefs.setDouble('balance', 0);
          prefs.setBool('isSubscribed', false);
          await deleteNotifications();
          await deleteAllKindTransactions();

          context.goNamed('/');
        }

        String title = context.translate('error');
        showPopupMessage(context, title, msg);
        print('something went wrong');
      }
    } catch (e) {
      print(e);
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: context.translate('wallet'), // 'Portfeuille'
      inAsyncCall: showSpinner,
      child: Container(
        margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
        padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 2 * fem, 15 * fem),
              padding:
                  EdgeInsets.fromLTRB(0 * fem, 15 * fem, 0 * fem, 15 * fem),
              width: 340 * fem,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffdae3ea)),
                color: Color(0xfff9f9f9),
                borderRadius: BorderRadius.circular(4 * fem),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.translate('my_balance'), // 'Mon solde'
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 12 * ffem,
                      fontWeight: FontWeight.w500,
                      height: 1.6666666667 * ffem / fem,
                      color: Color(0xff6d7d8b),
                    ),
                  ),
                  Text(
                    '$balance FCFA',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 20 * ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.2175 * ffem / fem,
                      color: Color(0xff25313c),
                    ),
                  ),
                  Text(
                    context.translate('total_benefit', args: {
                      'benefice': benefice.toStringAsFixed(1)
                    }), // 'Benefice total $benefice Fcfa'
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 8 * ffem,
                      fontWeight: FontWeight.w400,
                      height: 2.5 * ffem / fem,
                      color: Color(0xff6d7d8b),
                    ),
                  ),
                ],
              ),
            ),
            ReusableButton(
              title: context.translate('withdraw'), // 'Retrait'
              onPress: () {
                context.pushNamed(Retrait.id);
              },
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  showDragHandle: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  context: context,
                  builder: (context) {
                    return BottomHitory(transactions: transactions);
                  },
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Container(
                margin: EdgeInsets.fromLTRB(2 * fem, 0 * fem, 0 * fem, 0 * fem),
                padding:
                    EdgeInsets.fromLTRB(13 * fem, 13 * fem, 12 * fem, 12 * fem),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(7 * fem),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3f25313c),
                      offset: Offset(0 * fem, 0 * fem),
                      blurRadius: 2.1500000954 * fem,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.translate('history'), // 'Historique'
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 16 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.25 * ffem / fem,
                        color: orange,
                      ),
                    ),
                    Container(
                      width: 40 * fem,
                      height: 40 * fem,
                      child: Image.asset(
                        'assets/design/images/chevrondowncirclefill.png',
                        width: 40 * fem,
                        height: 40 * fem,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
