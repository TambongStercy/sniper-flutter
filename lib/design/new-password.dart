import 'dart:convert';

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
import 'package:http/http.dart' as http;
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization

// ignore: must_be_immutable
class NewPassword extends StatefulWidget {
  static const id = 'NewPassword';

  NewPassword({
    super.key,
    required this.email,
  });

  String email;

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  String get email => widget.email;
  String token = '';
  String? avatar = '';
  bool isSubscribed = false;
  String otp = '';

  String password = '';

  bool showSpinner = false;
  bool hasPP = false;

  late SharedPreferences prefs;

  Future<bool> changeAndValidate() async {
    if (password.isNotEmpty &&
        email.isNotEmpty &&
        otp.isNotEmpty &&
        otp.length == 4) {
      final regBody = {
        'email': email,
        'newPassword': password,
        'otp': int.parse(otp),
      };

      final response = await http.post(
        Uri.parse(validatefOTP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);

      final myToken = jsonResponse['token'];
      final user = jsonResponse['user'];
      final name = user['name'];
      final region = user['region'];
      final phone = user['phoneNumber'].toString();
      final msg = jsonResponse['message'] ?? '';

      final userCode = user['code'];
      final balance = user['balance'];
      final id = user['id'];
      avatar = !kIsWeb ? user['avatar'] : user['url'];
      isSubscribed = user['isSubscribed'] ?? false;

      if (response.statusCode == 200 && myToken != null) {
        if ((avatar != null || avatar != '') && !kIsWeb) {
          avatar = await mobilePathGetter('Profile Pictures/Your Picture.jpg');
          hasPP = true;
        } else {
          hasPP = false;
        }

        token = myToken;
        prefs.setString('id', id);
        prefs.setString('token', myToken);
        prefs.setString('email', email);
        prefs.setString('name', name);
        prefs.setString('region', region);
        prefs.setString('phone', phone);
        prefs.setString('code', userCode);
        prefs.setString('avatar', avatar ?? '');
        prefs.setInt('balance', balance);
        prefs.setBool('isSubscribed', isSubscribed);

        return true;
      } else {
        showPopupMessage(context, context.translate('error'), msg);
        return false;
      }
    } else {
      showPopupMessage(context, context.translate('incomplete_info'),
          context.translate('fill_all_fields'));
      return false;
    }
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

      final response = await http.get(Uri.parse(avatarPath));

      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        String fileName = generateUniqueFileName('pp', 'jpg');
        String folder = 'Profile Pictures';

        final permanentPath = kIsWeb
            ? avatarPath
            : await saveFileBytesLocally(folder, fileName, imageBytes);

        avatar = permanentPath;

        prefs.setString('avatar', permanentPath);
      } else {
        print('Image request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendFOTP() async {
    if (email.isNotEmpty) {
      final regBody = {
        'email': email,
      };

      final response = await http.post(
        Uri.parse(sendfOTP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        showPopupMessage(context, context.translate('otp_sent'), msg);
        return;
      } else {
        showPopupMessage(context, context.translate('error'), msg);
        return;
      }
    } else {
      showPopupMessage(context, context.translate('incomplete_info'),
          context.translate('fill_all_fields'));
      return;
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
                                'modify_and_validate_password'), // 'Modifier et Valider le mot de passe'
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
                            context.translate('enter_otp_and_password', args: {
                              'email': email
                            }), // 'Entrez le code OTP envoyé à $email et votre nouveau mot de passe'
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
                          numberOfFields: 4,
                          borderColor: Color(0xFF512DA8),
                          fieldWidth: 50.0,
                          margin: EdgeInsets.only(right: 8.0),
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {
                            print(code);
                          },
                          onSubmit: (String verificationCode) {
                            otp = verificationCode;
                            print('submit');
                          },
                        ),
                        SizedBox(height: 20 * fem),
                        CustomTextField(
                          hintText: context.translate(
                              'new_password'), // 'Nouveau mot de passe'
                          type: 3,
                          value: password,
                          onChange: (val) {
                            password = val;
                          },
                        ),
                        SizedBox(height: 20 * fem),
                        ReusableButton(
                          title: context.translate('validate'), // 'Valider'
                          lite: false,
                          onPress: () async {
                            try {
                              setState(() {
                                showSpinner = true;
                              });

                              final hasLogged =
                                  await changeAndValidate();

                              if (hasLogged) {
                                await downloadAvatar();
                                setState(() {
                                  showSpinner = false;
                                });

                                if (hasPP && isSubscribed) {
                                  context.go('/');
                                  return;
                                }

                                final pageToGo =
                                    hasPP ? Subscrition.id : PpUpload.id;
                                context.goNamed(pageToGo);
                                return;
                              }

                              setState(() {
                                showSpinner = false;
                              });
                            } catch (e) {
                              showPopupMessage(context,
                                  context.translate('error'), e.toString());
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
                                setState(() {
                                  showSpinner = true;
                                });

                                await sendFOTP();

                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                showPopupMessage(context,
                                    context.translate('error'), e.toString());
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            },
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              context.translate(
                                  'resend_otp'), // 'Renvoyer le code OTP'
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.5 * ffem / fem,
                                color: limeGreen,
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
