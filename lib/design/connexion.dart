import 'dart:convert';
// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/email-oublier.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;

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
  String token = '';
  String? avatar = '';
  bool isSubscribed = false;

  // Add new state variables for OTP verification
  bool showOtpScreen = false;
  String userId = '';
  String otp = '';

  String password = '';

  bool showSpinner = false;
  bool hasPP = false;

  late SharedPreferences prefs;

  // First step of login process
  Future<bool> initiateLogin() async {
    String msg = '';

    try {
      if (password.isNotEmpty && email.isNotEmpty) {
        final regBody = {
          'email': email,
          'password': password,
        };

        final response = await http.post(
          Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        final jsonResponse = jsonDecode(response.body);
        msg = jsonResponse['message'] ?? '';
        print(msg);
        print(response.statusCode);
        print(jsonResponse);
        if (response.statusCode == 200) {
          // Check if OTP verification is required
          if (jsonResponse['requireOTP'] == true) {
            final receivedUserId = jsonResponse['userId'];

            setState(() {
              userId = receivedUserId;
              showOtpScreen = true;
            });

            String title = context.translate('verification_required');
            showPopupMessage(context, title, msg);
            return false; // Return false to indicate login process is not complete yet
          }

          // If no OTP required (which should not happen with the new flow), proceed as before
          final myToken = jsonResponse['token'];
          final user = jsonResponse['user'];

          completeLoginProcess(myToken, user);
          return true;
        } else {
          String title = context.translate('error');
          print(msg);
          showPopupMessage(context, title, msg);
          return false;
        }
      } else {
        String msg = context.translate("fill_info");
        String title = context.translate("incomplete_info");
        showPopupMessage(context, title, msg);
        return false;
      }
    } on http.ClientException catch (e) {
      print('ClientException occurred: $e');
      String title = context.translate("network_error");
      String errorMsg = context.translate("network_error_message");
      showPopupMessage(context, title, errorMsg);
      return false;
    } catch (e) {
      print('An unexpected error occurred: $e');
      String title = context.translate("error");
      showPopupMessage(context, title, msg);
      return false;
    }
  }

  // Second step of login with OTP verification
  Future<bool> verifyLoginWithOTP() async {
    String msg = '';

    try {
      if (otp.isNotEmpty &&
          otp.length == 4 &&
          password.isNotEmpty &&
          email.isNotEmpty) {
        final regBody = {
          'email': email,
          'password': password,
          'otp': otp,
        };

        final response = await http.post(
          Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        final jsonResponse = jsonDecode(response.body);
        msg = jsonResponse['message'] ?? '';

        if (response.statusCode == 200) {
          final myToken = jsonResponse['token'];
          final user = jsonResponse['user'];

          completeLoginProcess(myToken, user);
          return true;
        } else {
          String title = context.translate('error');
          showPopupMessage(context, title, msg);
          return false;
        }
      } else {
        String msg = context.translate("enter_valid_otp");
        String title = context.translate("incomplete_info");
        showPopupMessage(context, title, msg);
        return false;
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
      String title = context.translate("error");
      showPopupMessage(context, title, msg);
      return false;
    }
  }

  // Helper method to complete the login process after successful authentication
  void completeLoginProcess(String myToken, dynamic user) {
    final name = user['name'];
    final region = user['region'];
    final phone = user['phoneNumber'].toString();

    final momo = user['momoNumber'];

    final userCode = user['code'];
    final balance = user['balance'].toDouble();
    final benefit = user['benefits'].floorToDouble();

    final id = user['id'];
    avatar = user['avatar'] ?? user['url'];
    isSubscribed = user['isSubscribed'] ?? false;
    if (avatar != null && avatar != '') {
      hasPP = true;
    } else {
      avatar = d_PP;
      hasPP = false;
    }

    token = myToken;
    prefs.setString('id', id);
    prefs.setString('token', myToken);
    prefs.setString('email', email);
    prefs.setString('name', name);
    prefs.setString('region', region);
    prefs.setString('phone', phone);
    if (momo != null) {
      prefs.setString('momo', momo.toString());
    }
    prefs.setString('code', userCode);
    prefs.setString('avatar', avatar ?? '');
    prefs.setDouble('balance', balance);
    prefs.setDouble('benefit', benefit);
    prefs.setBool('isSubscribed', isSubscribed);
  }

  Future<void> downloadAvatar() async {
    try {
      final avatarPath = avatar;

      if (avatarPath == null || avatarPath.isEmpty) {
        hasPP = false;
        return print('User does not have a Profile Photo');
      }

      if (kIsWeb) {
        return print('Already have URL for Web');
      }

      if (ppExist(avatarPath)) {
        hasPP = true;
        return print('Already Downloaded');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$downloadPP?email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      final avatarUrl = jsonResponse['url'];

      final imageData = jsonResponse['imageData'];

      if (response.statusCode == 200) {
        print(avatarUrl);
        final imageBytes = (imageData);
        String fileName = generateUniqueFileName('pp', 'jpg');
        // String fileName = 'Your Picture.jpg';
        String folder = 'Profile Pictures';

        final permanentPath = kIsWeb
            ? avatarUrl
            : await saveFileBytesLocally(folder, fileName, imageBytes);

        avatar = permanentPath;

        prefs.setString('avatar', permanentPath);
      } else {
        // Handle errors, e.g., image not found
        print('Image request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print(e);
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
                      width: double.infinity,
                      height: 500 * fem,
                      child: showOtpScreen
                          ? _buildOtpScreen(fem, ffem)
                          : _buildLoginScreen(fem, ffem),
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

  // Widget for the initial login screen
  Widget _buildLoginScreen(double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomTextField(
          hintText: context.translate('email'),
          type: 4,
          value: email,
          focusNode: emailFocusNode,
          onChange: (val) {
            email = val;
          },
        ),
        CustomTextField(
          hintText: context.translate('password'),
          type: 3,
          value: password,
          focusNode: passwordFocusNode,
          onChange: (val) {
            password = val;
          },
        ),
        SizedBox(height: 20 * fem),
        ReusableButton(
          title: context.translate("login"),
          lite: false,
          onPress: () async {
            try {
              setState(() {
                showSpinner = true;
              });

              final loginComplete = await initiateLogin();

              if (loginComplete) {
                await downloadAvatar();

                if (isSubscribed) {
                  if (hasPP) {
                    context.go('/');
                  } else {
                    context.goNamed(PpUpload.id);
                  }
                } else {
                  context.goNamed(Subscrition.id);
                }
              }

              setState(() {
                showSpinner = false;
              });
            } catch (e) {
              String msg = context.translate("login_failed");
              String title = context.translate("error");
              showPopupMessage(context, title, msg);
              print(e);
              setState(() {
                showSpinner = false;
              });
            }
          },
        ),
        SizedBox(height: 20 * fem),
        TextButton(
          onPressed: () {
            context.goNamed(
              Inscription.id,
              queryParameters: {'affiliationCode': affiliationCode},
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Text(
            context.translate("no_account_signup"),
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w700,
              height: 1.5 * ffem / fem,
              color: Color(0xff25313c),
            ),
          ),
        ),
        SizedBox(height: 10 * fem),
        TextButton(
          onPressed: () {
            context.pushNamed(EmailOublie.id);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Text(
            context.translate("forgot_password"),
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w700,
              height: 1.5 * ffem / fem,
              color: Color(0xff25313c),
            ),
          ),
        ),
      ],
    );
  }

  // Widget for the OTP verification screen
  Widget _buildOtpScreen(double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _fieldTitle(fem, ffem, context.translate('otp_code')),
        OtpTextField(
          numberOfFields: 4,
          borderColor: Color(0xFF512DA8),
          fieldWidth: 50.0,
          margin: EdgeInsets.only(right: 8.0),
          showFieldAsBox: true,
          onCodeChanged: (String code) {
            // Handle code change
          },
          onSubmit: (String verificationCode) {
            otp = verificationCode;
          },
        ),
        SizedBox(height: 20 * fem),
        ReusableButton(
          title: context.translate('verify'),
          lite: false,
          onPress: () async {
            try {
              setState(() {
                showSpinner = true;
              });

              final loginComplete = await verifyLoginWithOTP();

              if (loginComplete) {
                await downloadAvatar();

                if (isSubscribed) {
                  if (hasPP) {
                    context.go('/');
                  } else {
                    context.goNamed(PpUpload.id);
                  }
                } else {
                  context.goNamed(Subscrition.id);
                }
              }

              setState(() {
                showSpinner = false;
              });
            } catch (e) {
              String msg = context.translate("verification_failed");
              String title = context.translate("error");
              showPopupMessage(context, title, msg);
              print(e);
              setState(() {
                showSpinner = false;
              });
            }
          },
        ),
        SizedBox(height: 20 * fem),
        TextButton(
          onPressed: () {
            // Go back to login screen
            setState(() {
              showOtpScreen = false;
              otp = '';
              userId = '';
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Text(
            context.translate("back_to_login"),
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w700,
              height: 1.5 * ffem / fem,
              color: Color(0xff25313c),
            ),
          ),
        ),
        SizedBox(height: 10 * fem),
        TextButton(
          onPressed: () async {
            try {
              setState(() {
                showSpinner = true;
              });

              // Send the login request again to resend OTP
              await initiateLogin();

              setState(() {
                showSpinner = false;
              });
            } catch (e) {
              String msg = context.translate("otp_resend_failed");
              String title = context.translate("error");
              showPopupMessage(context, title, msg);
              print(e);
              setState(() {
                showSpinner = false;
              });
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Text(
            context.translate("resend_otp"),
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w700,
              height: 1.5 * ffem / fem,
              color: limeGreen,
            ),
          ),
        ),
      ],
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
