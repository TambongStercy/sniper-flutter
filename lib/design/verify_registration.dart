import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/utils.dart';
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
  final ApiService _apiService = ApiService();

  Future<void> _verifyOTP() async {
    if (userId.isNotEmpty && otp.isNotEmpty && otp.length == 6) {
      setState(() {
        showSpinner = true;
      });
      try {
        final response = await _apiService.verifyOtp(userId, otp);

        final msg = response['message'] ?? response['error'] ?? 'Unknown error';

        if (response['statusCode'] == 200 && response['success'] == true) {
          if (response['data'] is Map<String, dynamic>) {
            final responseData = response['data'] as Map<String, dynamic>;
            final myToken = responseData['token'] as String?;
            final dynamic userData = responseData['user'];

            if (myToken != null && userData is Map<String, dynamic>) {
              final user = userData;

            final name = user['name'] as String? ?? '';
            final region = user['region'] as String? ?? '';
            final phone = user['phoneNumber']?.toString() ?? '';
            final userCode = user['referralCode'] as String? ?? '';
            final balance = (user['balance'] as num?)?.toDouble() ?? 0.0;
            final id = user['_id'] as String? ?? userId;
            final isSubscribed = user['isSubscribed'] as bool? ?? false;

            prefs = await SharedPreferences.getInstance();
            await prefs.setString('id', id);
            await prefs.setString('email', email);
            await prefs.setString('name', name);
            await prefs.setString('token', myToken);
            await prefs.setString('region', region);
            await prefs.setString('phone', phone);
            await prefs.setString('code', userCode);
            await prefs.setDouble('balance', balance);
            await prefs.setString('avatar', user['avatar'] as String? ?? '');
            await prefs.setBool('isSubscribed', isSubscribed);

            String title = context.translate('success');
            showPopupMessage(context, title, msg, callback: () {
              if (mounted) context.goNamed(PpUpload.id);
            });
          } else {
            String title = context.translate('error');
            showPopupMessage(context, title,
                  'Verification successful, but incomplete login data received.');
            }
          } else {
            String title = context.translate('error');
            showPopupMessage(context, title,
                'Verification successful, but failed to retrieve user details.');
          }
        } else {
          String title = context.translate('error');
          showPopupMessage(context, title, msg);
        }
      } catch (e) {
        print('Error verifying OTP: $e');
        showPopupMessage(context, context.translate('error'),
            context.translate('error_occurred'));
      } finally {
        setState(() {
          showSpinner = false;
        });
      }
    } else {
      showPopupMessage(context, context.translate('incomplete_info'),
          context.translate('enter_valid_otp'));
    }
  }

  Future<void> _resendOTP() async {
    if (userId.isNotEmpty) {
      setState(() {
        showSpinner = true;
      });
      try {
        final response = await _apiService.resendVerificationOtp(userId);
        final msg = response['message'] ?? response['error'] ?? 'Unknown error';

        if (response['statusCode'] == 200 && response['success'] == true) {
          showPopupMessage(context, context.translate('otp_sent'), msg);
        } else {
          showPopupMessage(context, context.translate('error'), msg);
        }
      } catch (e) {
        print('Error resending OTP: $e');
        showPopupMessage(context, context.translate('error'),
            context.translate('error_occurred'));
      } finally {
        setState(() {
          showSpinner = false;
        });
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
                            numberOfFields: 6,
                            borderColor: Color(0xFF512DA8),
                            fieldWidth: 40.0,
                            margin: EdgeInsets.only(right: 8.0),
                            showFieldAsBox: true,
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
                          SizedBox(height: 20 * fem),
                          ReusableButton(
                            title: context.translate('verify'),
                            lite: false,
                            onPress: _verifyOTP,
                          ),
                          SizedBox(height: 20 * fem),
                          Center(
                            child: TextButton(
                              onPressed: _resendOTP,
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
