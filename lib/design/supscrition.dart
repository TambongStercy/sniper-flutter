import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/pricingcard.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension

// ignore: must_be_immutable
class Subscrition extends StatefulWidget {
  Subscrition({super.key});

  static const id = 'subscrition';

  @override
  State<Subscrition> createState() => _SubscritionState();
}

class _SubscritionState extends State<Subscrition> {
  bool showSpinner = false;

  late SharedPreferences prefs;

  String token = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token') ?? '';
    email = prefs.getString('email') ?? '';
  }

  Future<void> subscribe() async {
    try {
      if (token != '' && email != '') {
        final regBody = {
          'email': email,
        };

        final uri = Uri.parse('$subscriptiion?email=$email');

        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        final response =
            await http.post(uri, headers: headers, body: jsonEncode(regBody));

        final jsonResponse = jsonDecode(response.body);
        final paymentLink = jsonResponse['paymentLink'];
        final message = jsonResponse['message'] ?? '';

        if (response.statusCode == 200 && paymentLink != null) {
          launchURL(paymentLink);
        } else {
          String msg = message;
          String title = context.translate('something_went_wrong');
          showPopupMessage(context, title, msg);
        }
      }
    } catch (e) {
      String msg = e.toString();
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> logoutUser() async {
    final email = prefs.getString('email');
    final token = prefs.getString('token');
    final avatar = prefs.getString('avatar');

    var regBody = {
      'email': email,
      'token': token,
    };

    await http.post(
      Uri.parse(logout),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(regBody),
    );

    await deleteFile(avatar ?? '');
    // await unInitializeOneSignal();
    prefs.setString('token', '');
    prefs.setString('id', '');
    prefs.setString('email', '');
    prefs.setString('name', '');
    prefs.setString('token', '');
    prefs.setString('region', '');
    prefs.setString('phone', '');
    prefs.setString('code', '');
    prefs.setString('avatar', '');
    prefs.setInt('balance', 0);
    prefs.setBool('isSubscribed', false);
    await deleteNotifications();
    await deleteAllKindTransactions();

    String msg = 'You where successfully logged out';
    String title = 'Logout';

    showPopupMessage(context, title, msg);

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Container(
            margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
            padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
            width: double.infinity,
            child: ListView(
              children: [
                Container(
                  width: 771.27 * fem,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 46 * fem),
                        child: Text(
                          'Sniper Business Center',
                          textAlign: TextAlign.left,
                          style: SafeGoogleFont(
                            'Mulish',
                            fontSize: 30 * ffem,
                            fontWeight: FontWeight.w700,
                            height: 1.255 * ffem / fem,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 34 * fem),
                        child: Text(
                          context.translate('subscription'),
                          textAlign: TextAlign.left,
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 20 * ffem,
                            fontWeight: FontWeight.w800,
                            height: 1 * ffem / fem,
                            color: Color(0xfff49101),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 34 * fem),
                        child: Text(
                          context.translate('choose_subscription_plan'),
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 15 * ffem,
                            fontWeight: FontWeight.w400,
                            height: 1.4 * ffem / fem,
                            color: Color(0xff797979),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50.0,
                ),
                PricingCard(
                  type: 0,
                  onCommand: () async {
                    setState(() {
                      showSpinner = true;
                    });

                    await subscribe();

                    setState(() {
                      showSpinner = false;
                    });
                  },
                ),
                SizedBox(
                  height: 20 * fem,
                ),
                ReusableButton(
                  title: context.translate('logout'), // 'Deconnexion'
                  onPress: () async {
                    try {
                      setState(() {
                        showSpinner = true;
                      });

                      await logoutUser();

                      setState(() {
                        showSpinner = false;
                      });

                      String msg = context.translate(
                          'logged_out_successfully'); // 'You were successfully logged out'
                      String title = context.translate('logout'); // 'Logout'
                      showPopupMessage(context, title, msg);
                    } catch (e) {
                      setState(() {
                        showSpinner = false;
                      });
                      String msg = context.translate(
                          'error_occurred'); // 'An Error has occurred please try again'
                      String title = context.translate('error'); // 'Error'
                      showPopupMessage(context, title, msg);
                      print(e);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
