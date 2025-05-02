import 'dart:convert';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/new-password.dart';
import 'package:snipper_frontend/utils.dart';
// import 'package:http/http.dart' as http; // Remove http import
import 'package:snipper_frontend/localization_extension.dart'; // Ensure localization is set up
import 'package:snipper_frontend/api_service.dart'; // Import ApiService

class EmailOublie extends StatefulWidget {
  static const id = 'emailOublie';

  const EmailOublie({super.key});

  @override
  State<EmailOublie> createState() => _EmailOublieState();
}

class _EmailOublieState extends State<EmailOublie> {
  String email = '';
  final ApiService apiService = ApiService(); // Instantiate ApiService

  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> sendFOTP() async {
    if (email.trim().isEmpty) {
      String msg = context.translate('fill_info'); // Translated
      String title = context.translate('incomplete_info'); // Translated
      showPopupMessage(context, title, msg);
      return;
    }
    // Optional: Add domain validation here too if desired
    // if (!isValidEmailDomain(email.trim())) { ... }

    setState(() {
      showSpinner = true;
    });

    try {
      final response = await apiService.requestPasswordResetOtp(email.trim());
      final msg = response['message'] ?? '';

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        String title = context.translate('code_sent'); // Translated
        showPopupMessage(context, title,
            msg.isNotEmpty ? msg : context.translate('otp_sent_instructions'));

        // Navigate to NewPassword screen, passing the email
        context.pushNamed(
          NewPassword.id,
          extra: email.trim(),
        );
      } else {
        String title = context.translate('something_wrong'); // Translated
        showPopupMessage(context, title,
            msg.isNotEmpty ? msg : context.translate('otp_request_failed'));
        print(
            'API Error sendFOTP (EmailOublie): ${response['statusCode']} - $msg');
      }
    } catch (e) {
      print('Exception in sendFOTP (EmailOublie): $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
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
                              context
                                  .translate('app_name'), // Translated app name
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
                                  'forgot_password'), // Translated heading
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
                                  'enter_email'), // Translated description
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
                          _fieldTitle(fem, ffem,
                              context.translate('email')), // Translated "Email"
                          CustomTextField(
                            hintText: context
                                .translate('email_hint'), // Translated hint
                            fieldType: CustomFieldType.email,
                            value: email,
                            onChange: (val) {
                              email = val;
                            },
                          ),
                          SizedBox(
                            height: 20 * fem,
                          ),
                          ReusableButton(
                            title: context
                                .translate('send_otp'), // Translated "Send OTP"
                            lite: false,
                            onPress: () async {
                              try {
                                await sendFOTP();
                              } catch (e) {
                                String msg = e.toString();
                                String title = context
                                    .translate('error'); // Translated "Error"
                                showPopupMessage(context, title, msg);
                                print(e);
                              }
                            },
                          ),
                          SizedBox(
                            height: 20 * fem,
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                context.goNamed(Inscription.id);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                context.translate(
                                    'no_account'), // Translated "No account? Register"
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
          color: const Color(0xff6d7d8b),
        ),
      ),
    );
  }

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
