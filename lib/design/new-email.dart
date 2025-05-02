import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
// import 'package:http/http.dart' as http; // Remove http import
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization
import 'package:snipper_frontend/api_service.dart'; // Import ApiService

// ignore: must_be_immutable
class NewEmail extends StatefulWidget {
  static const id = 'NewEmail';

  NewEmail({
    super.key,
    required this.email,
  });

  String email;

  @override
  State<NewEmail> createState() => _NewEmailState();
}

class _NewEmailState extends State<NewEmail> {
  String get email => widget.email;
  final ApiService apiService = ApiService(); // Instantiate ApiService
  String token = '';
  String? avatar = '';
  bool isSubscribed = false;
  String otp = '';

  String id = '';

  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> changeAndValidate() async {
    // Basic validation
    if (email.isEmpty || otp.isEmpty || otp.length != 6) {
      showPopupMessage(context, context.translate('incomplete_info'),
          context.translate('fill_all_fields_correctly'));
      return;
    }

      // Add email domain validation
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
      // Call ApiService to verify email change
      final response = await apiService.verifyEmailChange(email.trim(), otp);

      final msg = response['message'] ?? '';

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        // Email change successful on backend.
        // The API might return updated user data. Assuming it does:
        final user =
            response['data']?['user'] ?? response['data']; // Adjust key

        if (user != null) {
          // Update local prefs with new email and potentially other updated info
          prefs.setString('email', email.trim());

          // Optionally update other fields if returned by API
          // Example:
          // final name = user['name'];
          // if (name != null) prefs.setString('name', name);
          // ... etc ...

          showPopupMessage(
              context,
              context.translate('success'),
              msg.isNotEmpty
                  ? msg
                  : context.translate('email_updated_successfully'));
          context.go('/'); // Navigate back after success
        } else {
          // Handle case where API succeeded but didn't return expected data
          print(
              "Email verify API success, but no user data returned: $response");
          showPopupMessage(
              context,
              context.translate('success'),
              context.translate(
                  'email_updated_partially')); // Indicate success but maybe data didn't sync
          context.go('/'); // Still navigate back
        }
      } else {
        // Handle API error
        showPopupMessage(context, context.translate('error'),
            msg.isNotEmpty ? msg : context.translate('email_update_failed'));
        print(
            'API Error changeAndValidate (Email): ${response['statusCode']} - $msg');
      }
    } catch (e) {
      print('Exception in changeAndValidate (Email): $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  Future<void> modifyEmailOTP() async {
    // Note: This function requests the OTP. It uses the ApiService.requestEmailChangeOtp
    // which relies on the user's auth token and doesn't need email/id in the body.

    setState(() {
      showSpinner = true;
    });

    try {
      // Call ApiService to request email change OTP
      final response = await apiService.requestEmailChangeOtp();
      final msg = response['message'] ?? '';

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        showPopupMessage(context, context.translate('otp_sent'),
            msg.isNotEmpty ? msg : context.translate('otp_sent_instructions'));
      } else {
        showPopupMessage(context, context.translate('error'),
            msg.isNotEmpty ? msg : context.translate('otp_request_failed'));
        print('API Error modifyEmailOTP: ${response['statusCode']} - $msg');
      }
    } catch (e) {
      print('Exception in modifyEmailOTP: $e');
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
    () async {
      await initSharedPref();
      if (mounted) {
        setState(() {
          // Update your UI with the desired changes.
        });
      }
    }();
  }

  Future<void> initSharedPref() async {
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
                              context.translate(
                                  'validate_email'), // 'Valider l\'adresse e-mail'
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
                              context.translate('enter_otp_for_email', args: {
                                'email': email
                              }), // 'Entrez le code OTP envoyé à $email'
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
                            title: context.translate('validate'), // 'Valider'
                            lite: false,
                            onPress: () async {
                              try {
                                await changeAndValidate();
                              } catch (e) {
                                showPopupMessage(context,
                                    context.translate('error'), e.toString());
                              }
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          Center(
                            child: TextButton(
                              onPressed: () async {
                                try {
                                  await modifyEmailOTP();
                                } catch (e) {
                                  showPopupMessage(context,
                                      context.translate('error'), e.toString());
                                }
                              },
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: Text(
                                context.translate(
                                    'resend_otp'), // 'Renvoyer le code OTP'
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

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
