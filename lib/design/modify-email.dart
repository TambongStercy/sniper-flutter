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
import 'package:snipper_frontend/theme.dart';

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
      final response = await apiService.requestEmailChangeOtp(email.trim());
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
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
                  context.translate('modify_email'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.translate('enter_new_email'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Email field
                CustomTextField(
                  fieldType: CustomFieldType.email,
                  hintText: 'Ex: Jeanpierre@gmail.com',
                  value: email,
                  onChange: (val) {
                    setState(() {
                      email = val;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: requestEmailModificationOtp,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      context.translate('send_otp_code'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resend OTP button
                Center(
                  child: TextButton(
                    onPressed: resendOTP,
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

  bool isValidEmailDomain(String email) {
    // Split the email at @ and check the domain part
    final parts = email.split('@');
    if (parts.length != 2) return false; // Not a valid email format

    final domain = parts[1].toLowerCase();

    // List of common email domains to accept
    final validDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'live.com',
      'aol.com',
      'icloud.com',
      'mail.ru',
      'protonmail.com',
      'pm.me',
      'yandex.ru',
      'zoho.com',
      'gmx.com',
      'gmx.net',
      'tutanota.com',
      'msn.com',
      'comcast.net',
      'verizon.net',
      'sbcglobal.net',
    ];

    return validDomains.any((valid) => domain.contains(valid)) ||
        domain.endsWith('.edu') ||
        domain.endsWith('.gov') ||
        domain.endsWith('.org') ||
        domain.endsWith('.net') ||
        domain.endsWith('.co') ||
        domain.endsWith('.io');
  }

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
