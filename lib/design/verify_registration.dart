import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/localization_extension.dart';

class VerifyRegistration extends StatefulWidget {
  static const id = 'verify_registration';

  const VerifyRegistration({
    super.key,
    required this.email,
    required this.userId,
  });

  final String email;
  final String userId;

  @override
  State<VerifyRegistration> createState() => _VerifyRegistrationState();
}

class _VerifyRegistrationState extends State<VerifyRegistration> {
  String get email => widget.email;
  String get userId => widget.userId;
  String otp = '';
  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> verifyRegistrationOTP() async {
    if (userId.isNotEmpty && otp.isNotEmpty && otp.length == 4) {
      final regBody = {
        'userId': userId,
        'otp': otp,
      };

      final response = await http.post(
        Uri.parse(verifyRegistration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        final myToken = jsonResponse['token'];
        final user = jsonResponse['user'];

        final name = user['name'] ?? '';
        final region = user['region'] ?? '';
        final phone = user['phoneNumber'] ?? '';
        final userCode = user['code'] ?? '';
        final balance = user['balance'] ?? 0;
        final id = user['id'] ?? '';
        final isSubscribed = user['isSubscribed'] ?? false;

        prefs = await SharedPreferences.getInstance();
        prefs.setString('id', id);
        prefs.setString('email', email);
        prefs.setString('name', name);
        prefs.setString('token', myToken);
        prefs.setString('region', region);
        prefs.setString('phone', phone.toString());
        prefs.setString('code', userCode);
        prefs.setInt('balance', balance);
        prefs.setString('avatar', '');
        prefs.setBool('isSubscribed', isSubscribed);

        String title = context.translate('success');
        showPopupMessage(context, title, msg);

        context.goNamed(PpUpload.id);
      } else {
        String title = context.translate('error');
        showPopupMessage(context, title, msg);
      }
    } else {
      showPopupMessage(context, context.translate('incomplete_info'),
          context.translate('enter_valid_otp'));
    }
  }

  Future<void> resendOTP() async {
    if (userId.isNotEmpty) {
      final regBody = {
        'userId': userId,
      };

      final response = await http.post(
        Uri.parse(createOTPLink),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        showPopupMessage(context, context.translate('otp_sent'), msg);
      } else {
        showPopupMessage(context, context.translate('error'), msg);
      }
    } else {
      showPopupMessage(context, context.translate('error'),
          context.translate('user_id_missing'));
    }
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
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 34 * fem),
                            child: Text(
                              context.translate('verify_your_email'),
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
                              context.translate('enter_otp_for_email',
                                  args: {'email': email}),
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
                          _fieldTitle(fem, ffem, context.translate('otp_code')),
                          OtpTextField(
                            numberOfFields: 4,
                            borderColor: Color(0xFF512DA8),
                            fieldWidth: 50.0,
                            margin: EdgeInsets.only(right: 8.0),
                            showFieldAsBox: true,
                            onCodeChanged: (String code) {
                              // Handle code change
                            },
                            onSubmit: (String verificationCode) {
                              otp = verificationCode;
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          ReusableButton(
                            title: context.translate('verify'),
                            lite: false,
                            onPress: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });

                                await verifyRegistrationOTP();

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
          fontSize: 14 * ffem,
          fontWeight: FontWeight.w700,
          height: 1.3333333333 * ffem / fem,
          letterSpacing: 0.400000006 * fem,
          color: Color(0xff6d7d8b),
        ),
      ),
    );
  }
}
