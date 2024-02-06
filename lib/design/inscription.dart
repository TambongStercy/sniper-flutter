import 'dart:convert';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/accueil.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;

class Inscription extends StatefulWidget {
  static const id = 'inscription';

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  String name = '';

  String email = '';

  String pw = '';

  String pwconfirm = '';

  String whatsapp = '';

  String countryCode = '237';

  String city = '';

  String code = '';

  bool isSubscribed = false;

  bool? check = false;

  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> registerUser(context) async {
    print(name);
    print(pw);
    print(name);
    print(email);
    print(pw);
    print(pwconfirm);
    print(whatsapp);
    print(countryCode);
    print(city);

    if (name.isNotEmpty &&
        pw.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        pw.isNotEmpty &&
        pwconfirm.isNotEmpty &&
        whatsapp.isNotEmpty &&
        countryCode.isNotEmpty &&
        city.isNotEmpty) {
      print('1');

      final regBody = {
        'name': name,
        'email': email,
        'password': pw,
        'confirm': pwconfirm,
        'phone': (countryCode + whatsapp),
        'region': city,
        'code': code,
      };

      print('2');

      final response = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );
      print('3');
      print(response.body);

      final jsonResponse = jsonDecode(response.body);

      final myToken = jsonResponse['token'];
      final user = jsonResponse['user'];

      final userCode = user['code'];
      final balance = user['balance'];
      final id = user['id'];
      isSubscribed = user['isSubscribed'] ?? false;

      print(user);

      if (myToken != null) {
        prefs.setString('id', id);
        prefs.setString('email', email);
        prefs.setString('name', name);
        prefs.setString('token', myToken);
        prefs.setString('region', city);
        prefs.setString('phone', whatsapp);
        prefs.setString('code', userCode);
        prefs.setInt('balance', balance);
        prefs.setString('avatar', '');
        prefs.setBool('isSubscribed', isSubscribed);

        await initializeOneSignal(id);

        Navigator.pushNamed(
          context,
          PpUpload.id,
        );
      } else {
        String msg = 'Please Try again';
        String title = 'Something went wrong';
        showPopupMessage(context, title, msg);
      }
    } else {
      String msg = 'Please fill in all information asked';
      String title = 'Information not complete';
      showPopupMessage(context, title, msg);
    }
  }

  void downloadPolicies() {
    launchURL(downloadPoliss);
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
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
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                color: Color(0xffffffff),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          25 * fem, 0 * fem, 0 * fem, 21.17 * fem),
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
                              'Inscription',
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
                              'Créez un compte pour développez votre réseau et augmentez vos revenus',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldTitle(fem, ffem, 'Nom et prenom'),
                              CustomTextField(
                                hintText: 'Ex: Jean Paul',
                                value: name,
                                onChange: (val) {
                                  name = val;
                                },
                              ),
                              _fieldTitle(fem, ffem, 'Email'),
                              CustomTextField(
                                hintText: 'Ex: Jeanpierre@gmai.com',
                                type: 4,
                                value: email,
                                onChange: (val) {
                                  email = val;
                                },
                              ),
                              _fieldTitle(fem, ffem, 'Mot de passe'),
                              CustomTextField(
                                hintText: 'Mot de passe',
                                type: 3,
                                value: pw,
                                onChange: (val) {
                                  // print(val);
                                  pw = val;
                                },
                              ),
                              _fieldTitle(fem, ffem, 'Confirmez mot de passe'),
                              CustomTextField(
                                hintText: 'Confirmez mot de passe',
                                type: 3,
                                value: pwconfirm,
                                onChange: (val) {
                                  pwconfirm = val;
                                },
                              ),
                              _fieldTitle(fem, ffem, 'Numero WhatsApp'),
                              CustomTextField(
                                hintText: 'Ex: 675090755',
                                value: whatsapp,
                                onChange: (val) {
                                  whatsapp = val;
                                },
                                getCountryCode: (code) {
                                  countryCode = code;
                                },
                                type: 5,
                              ),
                              _fieldTitle(fem, ffem, 'Ville'),
                              CustomTextField(
                                hintText: 'Ex: Douala',
                                value: city,
                                onChange: (val) {
                                  city = val;
                                },
                              ),
                              _fieldTitle(fem, ffem, 'Code parrain'),
                              CustomTextField(
                                hintText: 'EX: eG7iOp3',
                                value: code,
                                onChange: (val) {
                                  code = val;
                                },
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                10 * fem, 20 * fem, 0 * fem, 0 * fem),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextButton(
                                  onPressed: downloadPolicies,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(
                                        20 * fem, 0 * fem, 10 * fem, 20 * fem),
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(0 * fem,
                                              0 * fem, 17 * fem, 0 * fem),
                                          width: 20 * fem,
                                          height: 20 * fem,
                                          child: Image.asset(
                                            'assets/design/images/pictureaspdf.png',
                                            width: 20 * fem,
                                            height: 20 * fem,
                                          ),
                                        ),
                                        Text(
                                          'Conditions generales d’utilisations',
                                          style: SafeGoogleFont(
                                            'Montserrat',
                                            fontSize: 16 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: Color(0xff6d7d8b),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      check = !check!;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(
                                        20 * fem, 0 * fem, 20 * fem, 0 * fem),
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(0 * fem,
                                              0 * fem, 10 * fem, 0 * fem),
                                          width: 24 * fem,
                                          height: 24 * fem,
                                          child: Checkbox(
                                            value: check,
                                            onChanged: (val) {
                                              setState(() {
                                                check = val;
                                              });
                                            },
                                          ),
                                        ),
                                        Text(
                                          'J’accepte les termes et conditions',
                                          style: SafeGoogleFont(
                                            'Montserrat',
                                            fontSize: 16 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: Color(0xff6d7d8b),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20 * fem,
                          ),
                          ReusableButton(
                            clickable: check,
                            title: 'Inscription',
                            lite: false,
                            onPress: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });
                                if (pw != pwconfirm) {
                                  String msg =
                                      'The confirmation password does not corresponds to the password';
                                  String title = 'False Confirmation';
                                  showPopupMessage(context, title, msg);
                                  showSpinner = false;
                                  return print(msg);
                                }

                                // Authenticate here

                                await registerUser(context);

                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                String msg = e.toString();
                                String title = 'Error';
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
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.popAndPushNamed(
                                  context,
                                  Connexion.id,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Un compte ? Connexion',
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff25313c),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _fieldTitle(double fem, double ffem, String title) {
    return Container(
      margin: EdgeInsets.fromLTRB(49 * fem, 0 * fem, 49 * fem, 5 * fem),
      child: Text(
        title,
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 12 * ffem,
          fontWeight: FontWeight.w500,
          height: 1.3333333333 * ffem / fem,
          letterSpacing: 0.400000006 * fem,
          color: Color(0xff6d7d8b),
        ),
      ),
    );
  }

  void popUntilAndPush(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);

    // Now, push the new page as the first page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Accueil()),
    );
  }
}
