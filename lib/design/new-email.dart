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
import 'package:snipper_frontend/theme.dart';

// ignore: must_be_immutable
class NewEmail extends StatefulWidget {
  static const id = 'NewEmail';

  const NewEmail({
    super.key,
    required this.email,
  });

  final String email;

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
        final user = response['data']?['user'] ?? response['data'];

        if (user != null) {
          // Update local prefs with new email
          prefs.setString('email', email.trim());

          showPopupMessage(
              context,
              context.translate('success'),
              msg.isNotEmpty
                  ? msg
                  : context.translate('email_updated_successfully'));
          context.go('/'); // Navigate back after success
        } else {
          print(
              "Email verify API success, but no user data returned: $response");
          showPopupMessage(context, context.translate('success'),
              context.translate('email_updated_partially'));
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
      // Call ApiService to resend OTP using email and purpose
      final response = await apiService.resendOtpByEmail(email, 'changeEmail');
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
        setState(() {});
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Image.asset(
            'assets/design/images/logo.png',
            height: 50,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('validate_email'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context
                      .translate('enter_otp_for_email', args: {'email': email}),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // OTP input field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('otp_code'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      OtpTextField(
                        numberOfFields: 6,
                        borderColor: AppTheme.primaryBlue,
                        focusedBorderColor: AppTheme.primaryBlue,
                        showFieldAsBox: true,
                        borderWidth: 1.0,
                        fieldWidth: 45.0,
                        autoFocus: true,
                        keyboardType: TextInputType.number,
                        onSubmit: (String verificationCode) {
                          setState(() {
                            otp = verificationCode;
                          });
                        },
                        onCodeChanged: (String code) {
                          setState(() {
                            otp = code;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Validate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await changeAndValidate();
                      } catch (e) {
                        showPopupMessage(
                            context, context.translate('error'), e.toString());
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        context.translate('validate'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend OTP button
                Center(
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await modifyEmailOTP();
                      } catch (e) {
                        showPopupMessage(
                            context, context.translate('error'), e.toString());
                      }
                    },
                    child: Text(
                      context.translate('resend_otp'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
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
