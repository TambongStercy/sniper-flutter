import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/design/verify_registration.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart'; // Localization extension

class Inscription extends StatefulWidget {
  static const id = 'inscription';

  final String? affiliationCode;

  const Inscription({Key? key, this.affiliationCode}) : super(key: key);

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
  String? affiliationName;
  bool isFetchingAffiliation = false; // Track if fetching is in progress

  bool isSubscribed = false;
  bool? check = false;
  bool showSpinner = false;
  bool isChanged = false;

  late SharedPreferences prefs;


  Future<void> registerUser() async {
    String msg = '';

    try {
      if (name.isNotEmpty &&
          pw.isNotEmpty &&
          name.isNotEmpty &&
          email.isNotEmpty &&
          pw.isNotEmpty &&
          pwconfirm.isNotEmpty &&
          whatsapp.isNotEmpty &&
          countryCode.isNotEmpty &&
          city.isNotEmpty &&
          code.isNotEmpty) {
        // Add email domain validation
        if (!isValidEmailDomain(email.trim())) {
          String title = context.translate('invalid_email_domain');
          String message = context.translate('use_valid_email_provider');
          showPopupMessage(context, title, message);
          return;
        }

        final regBody = {
          'name': name,
          'email': email.trim(),
          'password': pw,
          'confirm': pwconfirm,
          'phone': (countryCode + whatsapp),
          'region': city,
          'code': code.trim(),
        };

        final response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        final jsonResponse = jsonDecode(response.body);
        msg = jsonResponse['message'] ?? '';

        if (response.statusCode == 200) {
          // Check if email verification is required
          if (jsonResponse['requireVerification'] == true) {
            final userId = jsonResponse['userId'];

            // Navigate to verification page
            context.pushNamed(
              VerifyRegistration.id,
              extra: {
                'email': email.trim(),
                'userId': userId,
              },
            );
            return;
          }

          // If no verification required, proceed as before
          final myToken = jsonResponse['token'];
          final user = jsonResponse['user'];

          final userCode = user['code'];
          final balance = user['balance'];
          final id = user['id'];
          isSubscribed = user['isSubscribed'] ?? false;

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

          print('1');
          String title = context.translate('success');
          print('2');
          showPopupMessage(context, title, msg);
          print('3');

          // context.goNamed(PpUpload.id);
        } else {
          String title = context.translate('error');
          showPopupMessage(context, title, msg);
        }
      } else {
        String msg = context.translate('fill_all_information');
        String title = context.translate('information_incomplete');
        showPopupMessage(context, title, msg);
      }
    } catch (e) {
      print(e);
      String title = context.translate('error');
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAffiliationName(affiliationCode ?? '');
    });
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    code = affiliationCode ?? '';
    print('affiliationCode: ');
    print(affiliationCode);
  }

  Future<void> fetchAffiliationName(String code) async {
    if (code.isEmpty) {
      setState(() {
        affiliationName = null;
      });
      return;
    }

    setState(() {
      isFetchingAffiliation = true; // Show progress indicator
    });

    try {
      final response =
          await http.get(Uri.parse('${url}get-affiliation?code=$code'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final fetchedName = jsonResponse['name'];

        setState(() {
          affiliationName = fetchedName; // Set the fetched name
        });
      } else {
        setState(() {
          affiliationName = null; // Set as not found
        });
      }
    } catch (e) {
      print('Error fetching affiliation: $e');
      setState(() {
        affiliationName = null; // Set as not found
      });
    } finally {
      setState(() {
        isFetchingAffiliation = false; // Hide progress indicator
      });
    }
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
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xffffffff),
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
                          const SizedBox(height: 40.0),
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
                                color: const Color(0xff000000),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 34 * fem),
                            child: Text(
                              context
                                  .translate('registration'), // 'Inscription'
                              textAlign: TextAlign.left,
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 20 * ffem,
                                fontWeight: FontWeight.w800,
                                height: 1 * ffem / fem,
                                color: const Color(0xfff49101),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 34 * fem),
                            child: Text(
                              context.translate(
                                  'create_account_msg'), // 'Créez un compte pour développez votre réseau...'
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 15 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.4 * ffem / fem,
                                color: const Color(0xff797979),
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
                              _fieldTitle(
                                  fem,
                                  ffem,
                                  context.translate(
                                      'full_name')), // 'Nom et prenom'
                              CustomTextField(
                                hintText: context.translate(
                                    'example_name'), // 'Ex: Jean Paul'
                                value: name,
                                onChange: (val) {
                                  name = val;
                                },
                              ),
                              _fieldTitle(fem, ffem, 'Email'),
                              CustomTextField(
                                hintText: context.translate(
                                    'example_email'), // 'Ex: Jeanpierre@gmail.com'
                                type: 4,
                                value: email,
                                onChange: (val) {
                                  email = val;
                                },
                              ),
                              _fieldTitle(
                                  fem,
                                  ffem,
                                  context
                                      .translate('password')), // 'Mot de passe'
                              CustomTextField(
                                hintText: context
                                    .translate('password'), // 'Mot de passe'
                                type: 3,
                                value: pw,
                                onChange: (val) {
                                  pw = val;
                                },
                              ),
                              _fieldTitle(
                                  fem,
                                  ffem,
                                  context.translate(
                                      'confirm_password')), // 'Confirmez mot de passe'
                              CustomTextField(
                                hintText: context.translate(
                                    'confirm_password'), // 'Confirmez mot de passe'
                                type: 3,
                                value: pwconfirm,
                                onChange: (val) {
                                  pwconfirm = val;
                                },
                              ),
                              _fieldTitle(
                                  fem,
                                  ffem,
                                  context.translate(
                                      'whatsapp_number')), // 'Numero WhatsApp'
                              CustomTextField(
                                hintText: context.translate(
                                    'example_whatsapp'), // 'Ex: 675090755'
                                value: whatsapp,
                                onChange: (val) {
                                  whatsapp = val;
                                },
                                getCountryDialCode: (code) {
                                  countryCode = code;
                                },
                                type: 5,
                              ),
                              _fieldTitle(fem, ffem,
                                  context.translate('city')), // 'Ville'
                              CustomTextField(
                                hintText: context
                                    .translate('example_city'), // 'Ex: Douala'
                                value: city,
                                onChange: (val) {
                                  city = val;
                                },
                              ),
                              _fieldTitle(fem, ffem,
                                  context.translate('sponsor_code') + ':',
                                  subtitle:
                                      (affiliationName ?? '').toLowerCase()),
                              CustomTextField(
                                hintText: 'EX: eG7iOp3',
                                value: affiliationCode ?? '',
                                readOnly: affiliationCode != null &&
                                    affiliationName != null &&
                                    !isChanged,
                                onChange: (val) {
                                  setState(() {
                                    code = val;
                                    isChanged = true;
                                  });
                                  fetchAffiliationName(
                                      val); // Fetch affiliation on code change
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
                                          context.translate(
                                              'terms_conditions'), // 'Conditions generales d'utilisations'
                                          style: SafeGoogleFont(
                                            'Montserrat',
                                            fontSize: 16 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: const Color(0xff6d7d8b),
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
                                          context.translate(
                                              'accept_terms_conditions'), // 'J'accepte les termes et conditions'
                                          style: SafeGoogleFont(
                                            'Montserrat',
                                            fontSize: 16 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: const Color(0xff6d7d8b),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20 * fem),
                          ReusableButton(
                            clickable: check,
                            title:
                                context.translate('sign_up'), // 'Inscription'
                            lite: false,
                            onPress: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });
                                if (pw != pwconfirm) {
                                  String msg = context
                                      .translate('password_confirmation_error');
                                  String title =
                                      context.translate('false_confirmation');
                                  showPopupMessage(context, title, msg);
                                  showSpinner = false;
                                  return print(msg);
                                }

                                await registerUser();

                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                String msg = e.toString();
                                String title = context.translate('error');
                                showPopupMessage(context, title, msg);
                                print(e);
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                context.goNamed(Connexion.id);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                context.translate(
                                    'already_have_account_login'), // 'Un compte ? Connexion'
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5 * ffem / fem,
                                  color: const Color(0xff25313c),
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

  Container _fieldTitle(double fem, double ffem, String title,
      {String subtitle = ""}) {
    return Container(
      margin: EdgeInsets.fromLTRB(49 * fem, 0 * fem, 49 * fem, 5 * fem),
      child: Text.rich(
        TextSpan(
          text: title, // Main title text
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 12 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.3333333333 * ffem / fem,
            letterSpacing: 0.400000006 * fem,
            color: const Color(0xff6d7d8b), // Default color for the title
          ),
          children: subtitle.isNotEmpty
              ? [
                  TextSpan(
                    text: ' $subtitle', // Subtitle text
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 12 * ffem,
                      fontWeight: FontWeight.bold, // Bold font for the subtitle
                      height: 1.3333333333 * ffem / fem,
                      color: Colors.red, // Red color for the subtitle
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
