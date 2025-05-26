import 'dart:convert';
import 'dart:io'; // Add back dart:io import for File class
import 'package:http/http.dart'
    as http; // Re-add http import for commented code in downloadAvatar

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/components/custom_otp_text_field.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization
import 'package:snipper_frontend/api_service.dart'; // Import ApiService
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/api_response.dart'; // Import ApiResponse

// ignore: must_be_immutable
class NewPassword extends StatefulWidget {
  static const id = 'NewPassword';

  const NewPassword({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  String get email => widget.email;
  final ApiService apiService = ApiService(); // Instantiate ApiService
  String token = '';
  String? avatar = '';
  bool isSubscribed = false;
  String otp = '';

  String password = '';

  bool showSpinner = false;
  bool hasPP = false;

  late SharedPreferences prefs;

  Future<bool> changeAndValidate() async {
    if (email.isEmpty || password.isEmpty || otp.isEmpty || otp.length != 6) {
      showPopupMessage(
          context,
          context.translate('incomplete_info'),
          context
              .translate('fill_all_fields_correctly')); // More specific message
      return false;
    }

    setState(() {
      showSpinner = true;
    });
    bool loggedInSuccessfully = false;

    try {
      final ApiResponse apiResponse =
          await apiService.resetPassword(email, otp, password);

      final String msg = apiResponse.message;

      if (apiResponse.isOverallSuccess) {
        // Password reset was successful according to API (status code and 'success': true)
        // No auto-login attempt here. User should be redirected to login page.
        showPopupMessage(context, context.translate('success'),
            context.translate('password_reset_success_login_prompt'));
        loggedInSuccessfully = true; // Indicates password reset was successful
      } else {
        // API call failed (non-2xx status or 'success': false, or network error)
        showPopupMessage(context, context.translate('error'),
            msg.isNotEmpty ? msg : context.translate('password_reset_failed'));
        print(
            'API Error changeAndValidate: ${apiResponse.statusCode} - $msg. Raw Error: ${apiResponse.rawError}');
        loggedInSuccessfully = false;
      }
    } catch (e) {
      // Catch-all for unexpected errors during the process (not network/API related from ApiService)
      print('Exception in changeAndValidate: $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
      loggedInSuccessfully = false;
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
    return loggedInSuccessfully; // This variable now more accurately reflects if a login or next step is expected
  }

  Future<void> downloadAvatar() async {
    try {
      final avatarPath = avatar;

      if (avatarPath == null || avatarPath.isEmpty) {
        hasPP = false;
        return print('User does not have a Profile Photo');
      }

      if (kIsWeb) {
        // If avatarPath is a full URL from the API, no download needed on web.
        hasPP = true;
        return print('Using URL for Web');
      }

      // Check if file already exists locally (assuming avatar stores local path after download)
      final file = File(avatarPath);
      if (await file.exists()) {
        hasPP = true;
        return print('Already Downloaded');
      }

      // If avatarPath is a URL from the API, download it.
      // This requires http import temporarily or a new ApiService method.
      // Temporarily keeping http import for this specific function.
      // Re-import http if needed for this block:
      // import 'package:http/http.dart' as http;

      // Uri? uri = Uri.tryParse(avatarPath);
      // if (uri == null || !uri.hasScheme) {
      //   print("Invalid avatar URL format: $avatarPath");
      //   hasPP = false;
      //   return;
      // }

      // final response = await http.get(uri);

      // if (response.statusCode == 200) {
      //   final imageBytes = response.bodyBytes;
      //   String fileName = generateUniqueFileName('pp', 'jpg'); // Ensure utils.dart is imported
      //   String folder = 'Profile Pictures';
      //   final permanentPath = await saveFileBytesLocally(folder, fileName, imageBytes);
      //   avatar = permanentPath; // Update avatar to local path
      //   prefs.setString('avatar', permanentPath);
      //   hasPP = true;
      // } else {
      //   print('Image request failed with status code ${response.statusCode}');
      //   hasPP = false;
      // }
    } catch (e) {
      print(e);
      hasPP = false;
    }
  }

  Future<void> sendFOTP() async {
    if (email.isEmpty) {
      showPopupMessage(context, context.translate('error'),
          context.translate('enter_email_address'));
      return;
    }

    setState(() {
      showSpinner = true;
    });

    try {
      final ApiResponse apiResponse =
          await apiService.requestPasswordResetOtp(email);
      final String msg = apiResponse.message;

      if (apiResponse.isOverallSuccess) {
        showPopupMessage(context, context.translate('otp_sent'),
            msg.isNotEmpty ? msg : context.translate('otp_sent_instructions'));
      } else {
        showPopupMessage(context, context.translate('error'),
            msg.isNotEmpty ? msg : context.translate('otp_request_failed'));
        print(
            'API Error sendFOTP: ${apiResponse.statusCode} - $msg. Raw Error: ${apiResponse.rawError}');
      }
    } catch (e) {
      // Catch-all for unexpected errors
      print('Exception in sendFOTP: $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
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
                  context.translate('modify_and_validate_password'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.translate('enter_otp_and_password',
                      args: {'email': email}),
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
                      const SizedBox(height: 8.0),
                      CustomOtpTextField(
                        numberOfFields: 6,
                        fieldWidth: 45.0,
                        fieldHeight: 50.0,
                        autoFocus: true,
                        textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: AppTheme.primaryBlue, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: AppTheme.primaryBlue, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: AppTheme.primaryBlue, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmit: (String verificationCode) {
                          setState(() {
                            otp = verificationCode;
                          });
                        },
                        onChanged: (String code) {
                          setState(() {
                            otp = code;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Password field
                CustomTextField(
                  fieldType: CustomFieldType.password,
                  hintText: context.translate('new_password'),
                  value: password,
                  onChange: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Validate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          showSpinner = true;
                        });

                        final passwordResetSuccessful =
                            await changeAndValidate();

                        if (passwordResetSuccessful) {
                          // No avatar download or other checks here.
                          // Navigate directly to the login page.
                          if (mounted) {
                            context.goNamed(
                                'connexion'); // Assuming 'connexion' is the route name for Connexion.id
                          }
                        }
                      } catch (e) {
                        // Error is handled within changeAndValidate or by the generic catch here.
                        // Ensure spinner is handled.
                        if (mounted) {
                          showPopupMessage(context, context.translate('error'),
                              e.toString());
                        }
                      } finally {
                        // Ensure spinner is always turned off if mounted
                        if (mounted) {
                          setState(() {
                            showSpinner = false;
                          });
                        }
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
                    onPressed: sendFOTP,
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
