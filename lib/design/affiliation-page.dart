import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/bonuscard.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/affiliation-page-filleuls-details.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart';

import 'package:snipper_frontend/utils.dart';

class Affiliation extends StatefulWidget {
  static const id = 'affiliation';

  @override
  State<Affiliation> createState() => _AffiliationState();
}

class _AffiliationState extends State<Affiliation> {
  String? code;
  String? link;
  bool showSpinner = true;
  bool isCode = true;
  String email = '';
  int directCount = 0;
  int indirectCount = 0;
  late SharedPreferences prefs;

  int basicRequirements = 2000;
  int proRequirements = 5000;
  int goldRequirements = 10000;

  int directSubCount = 0;
  int directNonSubCount = 0;
  int indirectSubCount = 0;
  int indirectNonSubCount = 0;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    code = prefs.getString('code');
    email = prefs.getString('email') ?? '';

    // Construct the URI
    Uri uri = Uri.parse('${frontEnd}inscription')
        .replace(queryParameters: {'affiliationCode': code});

    link = uri.toString();
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

        directSubCount = jsonResponse['directSubCount'] ?? 0;
        directNonSubCount = jsonResponse['directNonsubCount'] ?? 0;

        indirectSubCount = jsonResponse['indirectSubCount'] ?? 0;
        indirectNonSubCount = jsonResponse['indirectNonsubCount'] ?? 0;

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

          context.go('/');
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

    String? copy = isCode ? code : link;
    final directL = directCount;
    final indirectL = indirectCount;

    final directSubL = directSubCount;
    final indirectSubL = indirectSubCount;

    // final directNonSubL = directNonSubCount;
    // final indirectNonSubL = indirectNonSubCount;

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
      title: context.translate('your_affiliates'),
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
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isCode = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    15 * fem, 12 * fem, 15 * fem, 12 * fem),
                                decoration: BoxDecoration(
                                  color:
                                      isCode ? Color(0xfff49101) : Colors.grey,
                                  borderRadius: BorderRadius.circular(3 * fem),
                                ),
                                child: Text(
                                  context.translate('sponsor_code'),
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
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isCode = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    15 * fem, 12 * fem, 15 * fem, 12 * fem),
                                decoration: BoxDecoration(
                                  color:
                                      !isCode ? Color(0xfff49101) : Colors.grey,
                                  borderRadius: BorderRadius.circular(3 * fem),
                                ),
                                child: Text(
                                  context.translate('sponsor_link'),
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
                            14 * fem,
                            16 * fem,
                            14 * fem,
                            15 * fem,
                          ),
                          onPressed: () async {
                            copyToClipboard(context, copy ?? '');
                          },
                          icon: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // Wrap the text in Expanded
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 1 * fem, 0 * fem, 0 * fem),
                                  child: Text(
                                    copy ?? '',
                                    style: SafeGoogleFont(
                                      'Montserrat',
                                      fontSize: 12 * ffem,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2175 * ffem / fem,
                                      color: Color(0xff25313c),
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Use ellipsis overflow
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
                        context.pushNamed(
                          Filleuls.id,
                          extra: email,
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
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              offset: Offset(
                                0,
                                1,
                              ),
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
                                              context.translate(
                                                  'direct_godchilds'),
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
                                              context.translate(
                                                  'indirect_godchilds'),
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
                    context.translate('bonus_to_win'),
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
                    context.translate('number_of_shares', args: {'count': 0}),
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
