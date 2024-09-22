import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/bonuscard.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/affiliation-page-filleuls-details.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/design/splash1.dart';

import 'package:snipper_frontend/utils.dart';

class Affiliation extends StatefulWidget {
  static const id = 'affiliation';

  @override
  State<Affiliation> createState() => _AffiliationState();
}

class _AffiliationState extends State<Affiliation> {
  String? code;
  bool showSpinner = true;
  String email = '';
  int directCount = 0;
  int indirectCount = 0;
  late SharedPreferences prefs;

  int basicRequirements = 2000;
  int proRequirements = 5000;
  int goldRequirements = 10000;

  List directSubEmails = [];
  List directNonSubEmails = [];
  List indirectSubEmails = [];
  List indirectNonSubEmails = [];

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    code = prefs.getString('code');
    email = prefs.getString('email') ?? '';
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

      final url = Uri.parse('$getReferals?email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        directCount = jsonResponse['directCount'] ?? 0;
        indirectCount = jsonResponse['indirectCount'] ?? 0;

        directSubEmails = jsonResponse['directSep']['subEmails'] ?? [];
        directNonSubEmails = jsonResponse['directSep']['nonSubEmails'] ?? [];

        indirectSubEmails = jsonResponse['indirectSep']['subEmails'] ?? [];
        indirectNonSubEmails =
            jsonResponse['indirectSep']['nonSubEmails'] ?? [];

        // await saveTransactionList(gottenTransactions);
        // transactions = await getTransactions();

        setState(() {});

        print('all good');
        // print(transactions);
      } else {
        if (error == 'Accès refusé') {
          String title = "Erreur. Accès refusé.";
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

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Scene(),
            ),
            (route) => false,
          );
        }

        String title = 'Erreur';
        showPopupMessage(context, title, msg);

        // Handle errors,
        print('something went wrong');
      }
    } catch (e) {
      print(e);
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> parseVCF(String filePath) async {
    String vcfData = await File(filePath).readAsString();
    print(vcfData);
  }

  Future<void> requestPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      // Permission is granted, proceed with saving contacts
    } else {
      // Handle the case where the user denies the permission
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    final directL = directCount;
    final indirectL = indirectCount;

    final directSubL = directSubEmails.length;
    final indirectSubL = indirectSubEmails.length;

    final directNonSubL = directNonSubEmails.length;
    final indirectNonSubL = indirectNonSubEmails.length;

    final basic = max((directSubL / basicRequirements),
            (indirectSubL / basicRequirements)) *
        100;
    final pro =
        max((directSubL / proRequirements), (indirectSubL / proRequirements)) *
            100;
    final gold = max((directSubL / goldRequirements),
            (indirectSubL / goldRequirements)) *
        100;

    return SimpleScaffold(
      title: 'Vos Affiliates',
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(25 * fem, 20 * fem, 25 * fem, 100 * fem),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: code != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  15 * fem, 12 * fem, 15 * fem, 12 * fem),
                              decoration: BoxDecoration(
                                color: Color(0xfff49101),
                                borderRadius: BorderRadius.circular(3 * fem),
                              ),
                              child: Text(
                                'Code parrain',
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 12 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4166666667 * ffem / fem,
                                  letterSpacing: -0.5 * fem,
                                  color: Color(0xffffffff),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 50 * fem,
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(3 * fem),
                            bottomRight: Radius.circular(3 * fem),
                            bottomLeft: Radius.circular(3 * fem),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3f25313c),
                              offset: Offset(0 * fem, 0 * fem),
                              blurRadius: 1 * fem,
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.fromLTRB(
                              14 * fem, 16 * fem, 14 * fem, 15 * fem),
                          onPressed: () async {
                            copyToClipboard(context, code ?? '');
                          },
                          icon: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 1 * fem, 0 * fem, 0 * fem),
                                child: Text(
                                  code ?? '',
                                  style: SafeGoogleFont(
                                    'Montserrat',
                                    fontSize: 12 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2175 * ffem / fem,
                                    color: Color(0xff25313c),
                                  ),
                                ),
                              ),
                              Icon(Icons.copy),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 1 * fem, 0 * fem),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Filleuls(
                              email: email,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                            20 * fem, 8 * fem, 10 * fem, 9 * fem),
                        width: double.infinity,
                        height: 75 * fem,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ), // Optional: Add border radius
                          boxShadow: const [
                            BoxShadow(
                              color: Colors
                                  .black26, // You can set the shadow color as needed
                              spreadRadius: 1,
                              offset: Offset(
                                0,
                                1,
                              ), // Changes the position of the shadow
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 25 * fem, 0 * fem),
                                height: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 0 * fem, 4 * fem),
                                      width: double.infinity,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 29 * fem, 1 * fem),
                                            child: Text(
                                              'Nombre de filleuls direct: ',
                                              style: SafeGoogleFont(
                                                'Montserrat',
                                                fontSize: 12 * ffem,
                                                fontWeight: FontWeight.w500,
                                                height:
                                                    1.3333333333 * ffem / fem,
                                                letterSpacing:
                                                    0.400000006 * fem,
                                                color: Color(0xff6d7d8b),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (directL.toString()),
                                            style: SafeGoogleFont(
                                              'Montserrat',
                                              fontSize: 20 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.2175 * ffem / fem,
                                              color: Color(0xff25313c),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 29 * fem, 1 * fem),
                                            child: Text(
                                              'Nombre de filleuls indirect: ',
                                              style: SafeGoogleFont(
                                                'Montserrat',
                                                fontSize: 12 * ffem,
                                                fontWeight: FontWeight.w500,
                                                height:
                                                    1.3333333333 * ffem / fem,
                                                letterSpacing:
                                                    0.400000006 * fem,
                                                color: Color(0xff6d7d8b),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (indirectL.toString()),
                                            style: SafeGoogleFont(
                                              'Montserrat',
                                              fontSize: 20 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.2175 * ffem / fem,
                                              color: Color(0xff25313c),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  0 * fem, 0.01 * fem, 0 * fem, 0 * fem),
                              width: 18.47 * fem,
                              height: 18.48 * fem,
                              child: Image.asset(
                                'assets/design/images/chevrondowncirclefill-jLM.png',
                                width: 18.47 * fem,
                                height: 18.48 * fem,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Text(
                    'Bonus A gagner',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14 * ffem,
                      fontWeight: FontWeight.w500,
                      height: 1.4285714286 * ffem / fem,
                      color: Color(0xfff49101),
                    ),
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  BonusCard(
                    type: 1,
                    percentage: basic,
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  BonusCard(
                    type: 2,
                    percentage: pro,
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  BonusCard(
                    type: 3,
                    percentage: gold,
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Text(
                    'Nombre d’actions : 0',
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14 * ffem,
                      fontWeight: FontWeight.w500,
                      height: 1.4285714286 * ffem / fem,
                      color: Color(0xfff49101),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
