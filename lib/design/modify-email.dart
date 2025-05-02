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
// import 'package:http/http.dart' as http; // Remove http import
import 'package:snipper_frontend/localization_extension.dart'; // For localization
import 'package:snipper_frontend/api_service.dart'; // Import ApiService

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
  String otp = ''; // This seems unused in the OTP request logic

  final ApiService apiService = ApiService(); // Instantiate ApiService

  bool showSpinner = false;

  late SharedPreferences prefs;

  // Renamed function to avoid conflict with class name
  Future<void> requestEmailModificationOtp() async {
    // Basic validation
    if (email.trim().isEmpty) {
      String msg = context.translate('fill_all_information');
      String title = context.translate('information_incomplete');
      showPopupMessage(context, title, msg);
      return;
    }
    // Add domain validation before sending OTP request
    if (!isValidEmailDomain(email.trim())) {
      String title = context.translate('invalid_email_domain');
      String message = context.translate('use_valid_email_provider');
      showPopupMessage(context, title, message);
      return;
    }

    setState(() {
      showSpinner = true;
    });

    try {
      // Call ApiService to request email change OTP.
      // Assumes the backend identifies the user via token.
      // The new email address itself isn't typically sent in the *request* for OTP,
      // but rather when *verifying* the OTP with the new email.
      // However, if your `$modEmail` endpoint *does* require the new email when requesting OTP,
      // we'd need to adjust ApiService.requestEmailChangeOtp to accept it.
      // For now, assuming it only needs the token:
      final response = await apiService.requestEmailChangeOtp();
      final msg = response['message'] ?? '';

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        String title = context.translate('code_sent');
        showPopupMessage(context, title,
            msg.isNotEmpty ? msg : context.translate('otp_sent_instructions'));

        // Navigate to the OTP verification screen (NewEmail)
        context.pushNamed(
          NewEmail.id,
          extra: email.trim(), // Pass the new email to the verification screen
        );
      } else {
        // Handle API error
        String title = context.translate('something_went_wrong');
        showPopupMessage(context, title,
            msg.isNotEmpty ? msg : context.translate('otp_request_failed'));
        print(
            'API Error requestEmailModificationOtp: ${response['statusCode']} - $msg');
      }
    } catch (e) {
      print('Exception in requestEmailModificationOtp: $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  Future<void> resendOTP() async {
    // Resending OTP usually involves the same logic as requesting it initially.
    await requestEmailModificationOtp();
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
                            fieldType: CustomFieldType.email,
                            value: email,
                            onChange: (val) {
                              email = val;
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          _fieldTitle(fem, ffem,
                              context.translate('otp_code')), // 'Code OTP'
                          OtpTextField(
                            numberOfFields: 6,
                            borderColor: Color(0xFF512DA8),
                            fieldWidth: 40.0,
                            margin: EdgeInsets.only(right: 8.0),
                            showFieldAsBox: true,
                            keyboardType: TextInputType.text,
                            onCodeChanged: (String code) {
                              // Handle code change
                            },
                            onSubmit: (String verificationCode) {
                              otp = verificationCode;
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          ReusableButton(
                            title: context.translate(
                                'send_otp_code'), // 'Envoyer le code OTP'
                            lite: false,
                            onPress: () async {
                              try {
                                // No need for manual spinner handling here if done in the function
                                await requestEmailModificationOtp();
                              } catch (e) {
                                String msg = e.toString();
                                String title = context.translate('error');
                                showPopupMessage(context, title, msg);
                                print(e);
                                // Ensure spinner stops if error happens before function handles it
                                if (mounted)
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
                                  // No need for manual spinner handling here
                                  await resendOTP();
                                } catch (e) {
                                  String msg = e.toString();
                                  String title = context.translate('error');
                                  showPopupMessage(context, title, msg);
                                  print(e);
                                  // Ensure spinner stops
                                  if (mounted)
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
