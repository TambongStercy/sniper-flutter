import 'dart:convert';
// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/design/email-oublier.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
// import 'package:http/http.dart' as http; // Remove unused import

class Connexion extends StatefulWidget {
  static const id = 'connexion';

  final String? affiliationCode;

  const Connexion({Key? key, this.affiliationCode}) : super(key: key);

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  String email = '';
  // Remove token, avatar, isSubscribed from here, set in completeLoginProcess
  // String token = '';
  // String? avatar = '';
  // bool isSubscribed = false;

  // Add new state variables for OTP verification
  bool showOtpScreen = false;
  String userId = ''; // Store userId if OTP is required
  String otp = '';

  String password = '';

  bool showSpinner = false;
  bool hasPP = false;

  late SharedPreferences prefs;
  final ApiService _apiService = ApiService(); // Instantiate ApiService

  // Refactored login logic (Handles both initial login and OTP step)
  Future<void> _handleLogin() async {
    setState(() {
      showSpinner = true;
    });
    String msg = '';

    try {
      if (!showOtpScreen) {
        // --- Initial Login Attempt (Password Check) ---
        if (email.isNotEmpty && password.isNotEmpty) {
          final response = await _apiService.loginUser(email.trim(), password);
          msg =
              response['message'] ?? response['error'] ?? 'Unknown login error';

          // If password is correct (status 200), expect userId and prompt for OTP
          if (response['statusCode'] == 200) {
            final responseData = response['data'];
            final receivedUserId = responseData?['userId']; // Expect userId

            if (receivedUserId != null) {
              print(
                  "Login Step 1 Success. UserID: $receivedUserId. Message: $msg");
              // Always show OTP screen after successful password check
              setState(() {
                userId = receivedUserId; // Store userId for OTP verification
                showOtpScreen = true; // Show OTP input screen
              });
              // Show message from the API (e.g., "OTP sent")
              String title = context.translate('verification_required');
              showPopupMessage(context, title, msg);
            } else {
              // Handle case where status is 200 but userId is missing (API issue)
              print(
                  "Error: Login API returned 200 but missing userId. Response: $response");
              showPopupMessage(context, context.translate('error'),
                  context.translate('login_failed_unexpected'));
            }
          } else {
            // Login failed (invalid credentials or other error)
            String title = context.translate('error');
            showPopupMessage(context, title, msg);
            print('API Error Login Step 1: ${response['statusCode']} - $msg');
          }
        } else {
          // Fields not filled
          msg = context.translate("fill_info");
          String title = context.translate("incomplete_info");
          showPopupMessage(context, title, msg);
        }
      } else {
        // --- OTP Verification Step (Remains largely the same) ---
        if (userId.isNotEmpty && otp.length == 6) {
          final response = await _apiService.verifyOtp(userId, otp);
          msg = response['message'] ?? response['error'] ?? 'Unknown OTP error';

          if (response['statusCode'] == 200 && response['success'] == true) {
            // OTP Correct: Expect token and user data now
            final responseData = response['data'];
            final myToken = responseData?['token'];
            final user = responseData?['user'];
            if (myToken != null && user != null) {
              await completeLoginProcess(myToken, user);
            } else {
              print(
                  "Error: Missing token/user data after successful OTP. Response: $response");
              showPopupMessage(context, context.translate('error'),
                  context.translate('login_failed_incomplete_data'));
            }
          } else {
            // OTP verification failed
            String title = context.translate('error');
            showPopupMessage(context, title, msg);
            print(
                'API Error Login Step 2 (OTP): ${response['statusCode']} - $msg');
          }
        } else {
          // Invalid OTP format or missing userId
          msg = context.translate("enter_valid_otp");
          String title = context.translate("incomplete_info");
          showPopupMessage(context, title, msg);
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during login/OTP process: $e');
      String title = context.translate("error");
      showPopupMessage(context, title, context.translate("error_occurred"));
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  // Handles saving data and navigation after successful login/OTP verification
  Future<void> completeLoginProcess(
      String myToken, dynamic otpUserResponseData) async {
    // 1. Save the token immediately so getUserProfile can use it.
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', myToken);

    setState(() {
      showSpinner = true; // Show spinner while fetching profile
    });

    try {
      // 2. Fetch the full user profile using the new token
      final profileResponse = await _apiService.getUserProfile();

      if (profileResponse['success'] == true &&
          profileResponse['data'] != null) {
        final userProfile = profileResponse['data'] as Map<String, dynamic>;

        // 3. Extract comprehensive data from the profile response
        final name = userProfile['name'] as String? ?? '';
        final region = userProfile['region'] as String? ?? '';
        final country = userProfile['country'] as String? ?? '';
        final phone = userProfile['phoneNumber']?.toString() ?? '';
        final momo = userProfile['momoNumber']?.toString();
        final momoCorrespondent = userProfile['momoOperator'] as String?;
        final userEmail = userProfile['email'] as String? ??
            email; // Fallback to entered email
        final String? avatar = userProfile['avatar'] as String?;
        final avatarId = userProfile['avatarId'] as String?;
        final userRole = userProfile['role'] as String? ?? 'user';
        final userCode = userProfile['referralCode'] as String? ?? '';
        final balance = (userProfile['balance'] as num?)?.toDouble() ?? 0.0;
        final totalBenefits =
            (userProfile['totalBenefits'] as num?)?.toDouble() ??
                0.0; // Use totalBenefits
        final id =
            userProfile['_id'] as String? ?? userId; // Use _id from profile
        final List<dynamic> activeSubscriptions =
            userProfile['activeSubscriptions'] as List<dynamic>? ?? [];
        final bool isSubscribed =
            activeSubscriptions.isNotEmpty; // Derive from activeSubscriptions
        final List<String> interests =
            List<String>.from(userProfile['interests'] as List<dynamic>? ?? []);
        final profession = userProfile['profession'] as String?;
        final dob =
            userProfile['dob'] as String?; // Assuming dob is string YYYY-MM-DD
        final sex = userProfile['sex'] as String?;
        final List<String> language =
            List<String>.from(userProfile['language'] as List<dynamic>? ?? []);

        hasPP = avatar != null && avatar.isNotEmpty;
        final String finalAvatar = avatar ?? ''; // Use empty string if null

        // 4. Save ALL extracted data to prefs
        await prefs.setString('id', id);
        // Token is already saved
        await prefs.setString('email', userEmail);
        await prefs.setString('name', name);
        await prefs.setString('region', region);
        await prefs.setString('country', country);
        await prefs.setString('phone', phone);
        if (momo != null) await prefs.setString('momo', momo);
        if (momoCorrespondent != null)
          await prefs.setString('momoCorrespondent', momoCorrespondent);
        await prefs.setString('code', userCode);
        await prefs.setString('avatar', finalAvatar);
        if (avatarId != null) await prefs.setString('avatarId', avatarId);
        await prefs.setString('role', userRole);
        await prefs.setDouble('balance', balance);
        await prefs.setDouble(
            'benefit', totalBenefits); // Save totalBenefits as benefit
        await prefs.setBool('isSubscribed', isSubscribed);
        await prefs.setStringList('activeSubscriptions',
            activeSubscriptions.map((s) => s.toString()).toList());
        if (dob != null) await prefs.setString('dob', dob);
        if (sex != null) await prefs.setString('sex', sex);
        await prefs.setStringList('language', language);
        if (profession != null) await prefs.setString('profession', profession);
        await prefs.setStringList('interests', interests);

        // 5. Navigation Logic (remains the same)
        if (mounted) {
          if (!hasPP) {
            context.goNamed(PpUpload.id);
          } else if (!isSubscribed) {
            context.goNamed(Subscrition.id);
          } else {
            context.go('/');
          }
        }
      } else {
        // Handle failed profile fetch after successful OTP
        print(
            "Error: Failed to fetch user profile after login. Response: $profileResponse");
        String errorMsg = profileResponse['message'] ??
            profileResponse['error'] ??
            context.translate('fetch_profile_error');
        showPopupMessage(context, context.translate('error'), errorMsg);
      }
    } catch (e) {
      print("Exception during profile fetch: $e");
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

  // Placeholder - Actual download/caching might be needed for offline/performance
  Future<void> downloadAvatar() async {
    print(
        "Avatar check: URL is stored in prefs. Display handled by profileImage utility.");
    // Potentially implement local caching here if needed later
  }

  @override
  void initState() {
    super.initState();
    // No need to initSharedPref here, it's done in completeLoginProcess
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  String? get affiliationCode => widget.affiliationCode;

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
                          const SizedBox(height: 40.0),
                          Container(
                            margin: EdgeInsets.only(top: 46 * fem),
                            child: Text(
                              context.translate("sniper_business_center"),
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
                              showOtpScreen
                                  ? context.translate("verify_login")
                                  : context.translate("login"),
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
                              showOtpScreen
                                  ? context.translate("enter_otp_for_email",
                                      args: {'email': email})
                                  : context.translate("create_account_msg"),
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
                      padding: EdgeInsets.fromLTRB(
                          25 * fem, 0 * fem, 25 * fem, 32.83 * fem),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Conditional UI for Login / OTP ---
                          if (!showOtpScreen)
                            // --- Login Fields ---
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldTitle(
                                    fem, ffem, context.translate('email')),
                                CustomTextField(
                                  hintText: context.translate('example_email'),
                                  fieldType: CustomFieldType.email,
                                  value: email,
                                  onChange: (val) {
                                    email = val;
                                  },
                                  focusNode: emailFocusNode,
                                ),
                                SizedBox(height: 15 * fem),
                                _fieldTitle(
                                    fem, ffem, context.translate('password')),
                                CustomTextField(
                                  hintText: context.translate('password'),
                                  fieldType: CustomFieldType.password,
                                  value: password,
                                  onChange: (val) {
                                    password = val;
                                  },
                                  focusNode: passwordFocusNode,
                                ),
                                SizedBox(height: 10 * fem),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      context.pushNamed(EmailOublie.id);
                                    },
                                    child: Text(
                                      context.translate('forgot_password'),
                                      style: SafeGoogleFont(
                                        'Montserrat',
                                        fontSize: 14 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4 * ffem / fem,
                                        color: Color(0xfff49101),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            // --- OTP Field ---
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _fieldTitle(
                                    fem, ffem, context.translate('otp_code')),
                                OtpTextField(
                                  numberOfFields: 6,
                                  borderColor:
                                      Theme.of(context).colorScheme.primary,
                                  fieldWidth: 40.0,
                                  margin: EdgeInsets.only(right: 8.0),
                                  showFieldAsBox: true,
                                  keyboardType: TextInputType.text,
                                  onSubmit: (String verificationCode) {
                                    otp = verificationCode;
                                    // Optionally trigger login immediately on submit
                                    // _handleLogin();
                                  },
                                ),
                                // Optionally add a resend OTP button if backend supports it for login
                              ],
                            ),
                          SizedBox(height: 20 * fem),
                          // --- Login/Verify Button ---
                          ReusableButton(
                            title: !showOtpScreen
                                ? context.translate('connexion')
                                : context.translate('verify'),
                            lite: false,
                            onPress:
                                _handleLogin, // Always call the same handler
                          ),
                          SizedBox(height: 20 * fem),
                          // --- Registration Link ---
                          Center(
                            child: TextButton(
                              onPressed: () {
                                context.pushNamed(Inscription.id,
                                    queryParameters: {
                                      'affiliationCode':
                                          widget.affiliationCode ?? ''
                                    });
                              },
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: Text(
                                context.translate('no_account_register'),
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5 * ffem / fem,
                                  color: Color(0xff25313c),
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

  Future<void> verifyOtpAndProceed() async {
    if (userId == null || otp.length != 6) {
      showPopupMessage(context, context.translate('error'),
          context.translate('enter_valid_otp'));
      return;
    }

    setState(() {
      showSpinner = true;
    });

    try {
      final response = await _apiService.verifyOtp(userId, otp);

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300 &&
          response.containsKey('token')) {
        // --- Login OTP Verification Success ---
        final token = response['token'] as String;
        // The login response often contains more user details than registration verify
        final user = response['user'] as Map<String, dynamic>? ?? {};

        await completeLoginProcess(
            token, user); // Call the existing processing function
      } else {
        // --- OTP Verification Failed ---
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('invalid_otp_or_error');
        showPopupMessage(context, context.translate('error'), errorMsg);
      }
    } catch (e) {
      print('Exception during login OTP verification: $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred_retry'));
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }
}
