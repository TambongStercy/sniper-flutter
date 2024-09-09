import 'dart:convert';
// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/accueil.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

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
  String token = '';
  String? avatar = '';
  bool isSubscribed = false;
  String otp = '';

  String id = '';

  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> changeAndValidate(context) async {

    if (id.isNotEmpty &&
        email.isNotEmpty &&
        otp.isNotEmpty &&
        otp.length == 4) {
          

      final regBody = {
        'email': email,
        'id': id,
        'otp': (otp),
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final response = await http.post(
        Uri.parse(validateEOTP),
        headers: headers,
        body: regBody,
      );

      final jsonResponse = jsonDecode(response.body);

      final user = jsonResponse['user'];
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        final name = user['name'];
        final region = user['region'];
        final phone = user['phoneNumber'].toString();

        final userCode = user['code'];
        final balance = user['balance'];
        avatar = !kIsWeb ? user['avatar'] : user['url'];
        isSubscribed = user['isSubscribed'] ?? false;

        if ((avatar != null || avatar != '') && !kIsWeb) {
          avatar = await mobilePathGetter('Profile Pictures/Your Picture.jpg');
        }

        prefs.setString('email', email);
        prefs.setString('name', name);
        prefs.setString('region', region);
        prefs.setString('phone', phone);
        prefs.setString('code', userCode);
        prefs.setString('avatar', avatar ?? '');
        prefs.setInt('balance', balance);
        prefs.setBool('isSubscribed', isSubscribed);

        // await initializeOneSignal(id);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Accueil(),
          ),
          (route) => false,
        );
      } else {
        // String msg = 'Please Try again';
        String title = 'Something went wrong';
        showPopupMessage(context, title, msg);
      }
    } else {
      String msg = 'Please fill in all information asked';
      String title = 'Information not complete';
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> ModifyEmailOTP(context) async {
    if (email.isNotEmpty) {
      final regBody = {
        'email': email,
        'id': id,
      };

      final response = await http.post(
        Uri.parse(modEmail),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);

      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        String title = 'Code Sent';
        showPopupMessage(context, title, msg);

        return;
      } else {
        // String msg = 'Please Try again';
        String title = 'Something went wrong';
        showPopupMessage(context, title, msg);
        return;
      }
    } else {
      String msg = 'Please fill in all information asked';
      String title = 'Information not complete';
      showPopupMessage(context, title, msg);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    // Create anonymous function:
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
                        25 * fem,
                        0 * fem,
                        0 * fem,
                        21.17 * fem,
                      ),
                      width: 771.27 * fem,
                      // height: 275.83 * fem,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 40.0,
                          ),
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
                              'Valider l\'adresse e-mail',
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
                              'Entrez le code OTP envoyé à $email',
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
                          _fieldTitle(fem, ffem, 'Code OTP'),
                          OtpTextField(
                            numberOfFields: 4,
                            borderColor: Color(0xFF512DA8),
                            fieldWidth: 50.0,
                            margin: EdgeInsets.only(right: 8.0),
                            //set to true to show as box or false to show as dash
                            showFieldAsBox: true,
                            //runs when a code is typed in
                            onCodeChanged: (String code) {
                              print(code);
                              // otp = code;
                            },
                            //runs when every textfield is filled
                            onSubmit: (String verificationCode) {
                              otp = verificationCode;
                              print('submit');
                            }, // end onSubmit
                          ),
                          SizedBox(
                            height: 20 * fem,
                          ),
                          ReusableButton(
                            title: 'Valider',
                            lite: false,
                            onPress: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });

                                await changeAndValidate(context);

                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                String msg = e.toString();
                                String title = 'Error';
                                showPopupMessage(context, title, msg);
                                print(e);
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            },
                          ),
                          SizedBox(
                            height: 20 * fem,
                          ),
                          SizedBox(
                            height: 10 * fem,
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () async {
                                try {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  await ModifyEmailOTP(context);

                                  setState(() {
                                    showSpinner = false;
                                  });
                                } catch (e) {
                                  String msg = e.toString();
                                  String title = 'Error';
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
                                'Renvoyer le code OTP',
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
    Navigator.popUntil(context, (route) => route.isFirst);

    // Now, push the new page as the first page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Accueil()),
    );
  }
}
