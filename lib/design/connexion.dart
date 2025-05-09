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
    final screenSize = MediaQuery.of(context).size;
    // final double expandedAppBarHeight = screenSize.height * 0.30; // No longer needed
    // final double collapsedAppBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top; // No longer needed

    return Scaffold(
      backgroundColor: Color(0xFFFFF8F0),
      extendBodyBehindAppBar: true, // To allow gradient to go behind AppBar
      appBar: AppBar(
        // Simplified AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // No shadow
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenSize.height * 0.6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8CE98), // User's manually updated color
                    Color(0xFFFFF3E0).withOpacity(0.8),
                  ],
                  stops: [0.0, 1.0], // User's manually updated stops
                ),
              ),
            ),
          ),
          ModalProgressHUD(
            inAsyncCall: showSpinner,
            // Replace CustomScrollView with SingleChildScrollView
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    top: kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        20, // Adjust as needed
                    left: 24.0,
                    right: 24.0,
                    bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add logo here
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                      child: Center(
                        child: Image.asset(
                          'assets/design/images/logo-sbc-final-1-AdP.png', // Connexion logo path
                          height:
                              screenSize.height * 0.12, // Adjust size as needed
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Original content starts
                    Text(
                      context.translate('login'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.translate('enter_credentials'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!showOtpScreen) ...[
                      // Email field
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          context.translate('email'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[750],
                          ),
                        ),
                      ),
                      CustomTextField(
                        fieldType: CustomFieldType.email,
                        hintText: context.translate('email_hint'),
                        value: email,
                        focusNode: emailFocusNode,
                        onChange: (value) => setState(() => email = value),
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          context.translate('password'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[750],
                          ),
                        ),
                      ),
                      CustomTextField(
                        fieldType: CustomFieldType.password,
                        hintText: context.translate('password'),
                        value: password,
                        focusNode: passwordFocusNode,
                        onChange: (value) => setState(() => password = value),
                      ),
                      const SizedBox(height: 16),

                      // Forgot password button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.goNamed(EmailOublie.id);
                          },
                          child: Text(
                            context.translate('forgot_password'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              context.translate('login'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Register button
                      GestureDetector(
                        onTap: () {
                          if (widget.affiliationCode != null) {
                            context.goNamed(
                              Inscription.id,
                              queryParameters: {
                                'code': widget.affiliationCode!
                              },
                            );
                          } else {
                            context.goNamed(Inscription.id);
                          }
                        },
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              text: context.translate('no_account_signup'),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // OTP Verification UI
                      Text(
                        context.translate('verify_login'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        context
                            .translate('enter_otp_for_email')
                            .replaceAll('{email}', email),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // OTP input field
                      OtpTextField(
                        numberOfFields: 6,
                        borderColor: Theme.of(context).colorScheme.primary,
                        focusedBorderColor:
                            Theme.of(context).colorScheme.primary,
                        showFieldAsBox: true,
                        onSubmit: (code) {
                          setState(() {
                            otp = code;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              context.translate('verify'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Back to login button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showOtpScreen = false;
                            otp = '';
                          });
                        },
                        child: Center(
                          child: Text(
                            context.translate('back_to_login'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ], // children of Column
                ), // End of Column widget
              ), // End of Padding
            ), // End of SingleChildScrollView
          ), // This closes ModalProgressHUD
        ],
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
