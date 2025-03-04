import 'dart:convert';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/new-email.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart'; // For localization

class ModifyEmail extends StatefulWidget {
  static const id = 'modifyEmail';

  const ModifyEmail({super.key});

  @override
  State<ModifyEmail> createState() => _ModifyEmailState();
}

class _ModifyEmailState extends State<ModifyEmail> {
  String email = '';
  String id = '';
  String token = '';
  String otp = '';

  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> ModifyEmail() async {
    if (email.isNotEmpty) {
      final regBody = {
        'email': email,
        'id': id,
        'otp': otp,
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final response = await http.post(
        Uri.parse(modEmail),
        headers: headers,
        body: (regBody),
      );

      final jsonResponse = jsonDecode(response.body);

      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        String title = context.translate('code_sent');

        context.pushNamed(
          NewEmail.id,
          extra: email,
        );

        showPopupMessage(context, title, msg);
        return;
      } else {
        String title = context.translate('something_went_wrong');

        showPopupMessage(context, title, msg);
        return;
      }
    } else {
      String msg = context.translate('fill_all_information');
      String title = context.translate('information_incomplete');
      showPopupMessage(context, title, msg);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    token = prefs.getString('token') ?? '';
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
                              context.translate(
                                  'modify_email'), // 'Modifiez votre e-mail'
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
                              context.translate(
                                  'enter_new_email'), // 'Entrez la nouvelle adresse e-mail'
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldTitle(
                              fem, ffem, context.translate('email')), // 'Email'
                          CustomTextField(
                            hintText: 'Ex: Jeanpierre@gmail.com',
                            type: 4,
                            value: email,
                            onChange: (val) {
                              email = val;
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          _fieldTitle(fem, ffem,
                              context.translate('otp_code')), // 'Code OTP'
                          OtpTextField(
                            numberOfFields: 4,
                            borderColor: Color(0xFF512DA8),
                            fieldWidth: 50.0,
                            margin: EdgeInsets.only(right: 8.0),
                            showFieldAsBox: true,
                            onCodeChanged: (String code) {
                              print(code);
                            },
                            onSubmit: (String verificationCode) {
                              otp = verificationCode;
                              print('submit');
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          ReusableButton(
                            title: context.translate(
                                'send_otp_code'), // 'Envoyer le code OTP'
                            lite: false,
                            onPress: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });

                                await ModifyEmail();

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
                              onPressed: () async {
                                try {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  await resendOTP();

                                  setState(() {
                                    showSpinner = false;
                                  });
                                } catch (e) {
                                  showPopupMessage(context,
                                      context.translate('error'), e.toString());
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: Text(
                                context.translate('resend_otp'),
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5 * ffem / fem,
                                  color: limeGreen,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20 * fem),
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

  Future<void> resendOTP() async {
    if (id.isNotEmpty) {
      setState(() {
        showSpinner = true;
      });
      final regBody = {
        'userId': id,
      };

      final response = await http.post(
        Uri.parse(createOTPLink),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        showPopupMessage(
            context, context.translate('otp_sent') + ': ' + email, msg);
      } else {
        showPopupMessage(context, context.translate('error'), msg);
      }
    } else {
      showPopupMessage(context, context.translate('error'),
          context.translate('user_id_missing'));
    }
    setState(() {
      showSpinner = false;
    });
  }

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
