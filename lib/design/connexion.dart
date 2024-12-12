import 'dart:convert';
// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/email-oublier.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;

class Connexion extends StatefulWidget {
  static const id = 'connexion';

  final String? affiliationCode;

  const Connexion({Key? key, this.affiliationCode}) : super(key: key);

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  String email = '';
  String token = '';
  String? avatar = '';
  bool isSubscribed = false;

  String password = '';

  bool showSpinner = false;
  bool hasPP = false;

  late SharedPreferences prefs;

  Future<bool> loginUser() async {
    String msg = '';

    try {
      if (password.isNotEmpty && email.isNotEmpty) {
        final regBody = {
          'email': email,
          'password': password,
        };

        final response = await http.post(
          Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        final jsonResponse = jsonDecode(response.body);
        msg = jsonResponse['message'] ?? '';

        if (response.statusCode == 200) {
          final myToken = jsonResponse['token'];
          final user = jsonResponse['user'];

          final name = user['name'];
          final region = user['region'];
          final phone = user['phoneNumber'].toString();

          final momo = user['momoNumber'];

          final userCode = user['code'];
          final balance = user['balance'].toDouble();

          final id = user['id'];
          avatar = user['avatar'] ?? user['url'];
          isSubscribed = user['isSubscribed'] ?? false;
          if (avatar != null && avatar != '') {
            hasPP = true;
          } else {
            avatar = d_PP;
            hasPP = false;
          }

          token = myToken;
          prefs.setString('id', id);
          prefs.setString('token', myToken);
          prefs.setString('email', email);
          prefs.setString('name', name);
          prefs.setString('region', region);
          prefs.setString('phone', phone);
          if (momo != null) {
            prefs.setString('momo', momo.toString());
          }
          prefs.setString('code', userCode);
          prefs.setString('avatar', avatar ?? '');
          prefs.setDouble('balance', balance);
          prefs.setBool('isSubscribed', isSubscribed);

          return true;
        } else {
          String title = 'Erreur';
          showPopupMessage(context, title, msg);
          return false;
        }
      } else {
        String msg = context.translate("fill_info");
        String title = context.translate("incomplete_info");
        showPopupMessage(context, title, msg);
        return false;
      }
    } on http.ClientException catch (e) {
      print('ClientException occurred: $e');
      print('An error occurred. Please be careful when trying to login.');
      String title = context.translate("network_error");
      String errorMsg = context.translate("network_error_message");
      showPopupMessage(context, title, errorMsg);
      return false;
    } catch (e) {
      print('An unexpected error occurred: $e');
      print('An error occurred. Please be careful when trying to login.');
      String title = context.translate("error");
      showPopupMessage(context, title, msg);
      return false;
    }
  }

  Future<void> downloadAvatar() async {
    try {
      final avatarPath = avatar;

      if (avatarPath == null || avatarPath.isEmpty) {
        hasPP = false;
        return print('User does not have a Profile Photo');
      }

      if (kIsWeb) {
        return print('Already have URL for Web');
      }

      if (ppExist(avatarPath)) {
        hasPP = true;
        return print('Already Downloaded');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$downloadPP?email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      final avatarUrl = jsonResponse['url'];

      final imageData = jsonResponse['imageData'];

      if (response.statusCode == 200) {
        print(avatarUrl);
        final imageBytes = (imageData);
        String fileName = generateUniqueFileName('pp', 'jpg');
        // String fileName = 'Your Picture.jpg';
        String folder = 'Profile Pictures';

        final permanentPath = kIsWeb
            ? avatarUrl
            : await saveFileBytesLocally(folder, fileName, imageBytes);

        avatar = permanentPath;

        prefs.setString('avatar', permanentPath);
      } else {
        // Handle errors, e.g., image not found
        print('Image request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  String? get affiliationCode => widget.affiliationCode;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffffffff),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                        25 * fem,
                        0 * fem,
                        0 * fem,
                        21.17 * fem,
                      ),
                      width: 771.27 * fem,
                      height: 275.83 * fem,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 40.0,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 46 * fem),
                            child: Text(
                              context.translate("sniper_business_center"),
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
                              context.translate("login"),
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
                              context.translate("create_account_msg"),
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
                    Container(
                      width: double.infinity,
                      height: 500 * fem,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextField(
                            hintText: context.translate('email'),
                            type: 4,
                            value: email,
                            onChange: (val) {
                              email = val;
                            },
                          ),
                          CustomTextField(
                            hintText: context.translate('password'),
                            type: 3,
                            value: password,
                            onChange: (val) {
                              password = val;
                            },
                          ),
                          SizedBox(
                            height: 20 * fem,
                          ),
                          ReusableButton(
                            title: context.translate("login"),
                            lite: false,
                            onPress: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });

                                final hasLogged = await loginUser();

                                if (hasLogged) {
                                  await downloadAvatar();
                                  setState(() {
                                    showSpinner = false;
                                  });

                                  if (isSubscribed) {
                                    if (hasPP) {
                                      context.go('/');
                                    } else {
                                      context.goNamed(PpUpload.id);
                                    }
                                  } else {
                                    context.goNamed(Subscrition.id);
                                  }
                                }

                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                String msg = context.translate("login_failed");
                                String title = context.translate("error");
                                showPopupMessage(context, title, msg);
                                print(e);
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            },
                          ),
                          SizedBox(
                            height: 20 * fem,
                          ),
                          TextButton(
                            onPressed: () {
                              context.goNamed(
                                Inscription.id,
                                queryParameters: {
                                  'affiliationCode': affiliationCode
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              context.translate("no_account_signup"),
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.5 * ffem / fem,
                                color: Color(0xff25313c),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10 * fem,
                          ),
                          TextButton(
                            onPressed: () {
                              context.pushNamed(EmailOublie.id);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              context.translate("forgot_password"),
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.5 * ffem / fem,
                                color: Color(0xff25313c),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
