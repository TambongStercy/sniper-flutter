import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/components/custom_otp_text_field.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/components/button.dart';

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

        final msg = response.message;

        if (response.statusCode == 200 && response.apiReportedSuccess) {
          if (response.body['data'] is Map<String, dynamic>) {
            final responseData = response.body['data'] as Map<String, dynamic>;
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
        final msg = response.message;

        if (response.statusCode == 200 && response.apiReportedSuccess) {
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
                  context.translate('verify_login'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context
                      .translate('enter_otp_for_email')
                      .replaceAll('{email}', email),
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

                const SizedBox(height: 32),

                // Verify button
                ReusableButton(
                  title: context.translate('verify'),
                  onPress: _verifyOTP,
                  lite: false,
                  mh: 0,
                ),

                const SizedBox(height: 16),

                // Resend OTP button
                Center(
                  child: TextButton(
                    onPressed: _resendOTP,
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
}
