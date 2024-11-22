import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/modify-email.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart';

class ProfileMod extends StatefulWidget {
  static const id = 'profile-modify';

  @override
  State<ProfileMod> createState() => _ProfileModState();
}

class _ProfileModState extends State<ProfileMod> {
  late SharedPreferences prefs;
  bool showSpinner = false;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    id = prefs.getString('id');
    token = prefs.getString('token');
    email = prefs.getString('email') ?? '';
    name = prefs.getString('name');
    region = prefs.getString('region');
    code = prefs.getString('code');
    phone = prefs.getString('phone') ?? '';
    momo = prefs.getString('momo');
    avatar = prefs.getString('avatar') ?? "";

    final country1 = getCountryFromPhoneNumber(phone);

    countryCode = country1!.dialCode;
    countryCode2 = country1.code;

    phone = phone.substring(country1.dialCode.length);

    if (momo != null) {
      final country2 = getCountryFromPhoneNumber(momo ?? '');

      if (country2 != null) {
        cCode = country2.dialCode;
        cCode2 = country2.code;
        momo = momo?.substring(country2.dialCode.length);
      }
    }

    showSpinner = false;
  }

  String? id;
  String email = '';
  String? name;
  String? region;
  String phone = '';
  String? momo = '';
  String cCode = '237';
  String cCode2 = 'CM';
  String? token;
  String? code;
  String avatar = '';
  String countryCode = '237';
  String countryCode2 = 'CM';

  Future<void> modifyUser() async {
    String msg = '';
    String error = '';
    try {
      if (email.isNotEmpty &&
          name!.isNotEmpty &&
          region!.isNotEmpty &&
          phone.isNotEmpty &&
          code!.isNotEmpty) {
        final sendPone = countryCode + phone;
        final sendMomo = momo == '' || momo == null ? null : cCode + momo!;

        final regBody = {
          'id': id,
          'email': email,
          'name': name,
          'region': region,
          'phone': sendPone,
          'momo': sendMomo,
          'code': code,
          'token': token,
        };

        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        final response = await http.post(
          Uri.parse(update),
          headers: headers,
          body: jsonEncode(regBody),
        );

        final jsonResponse = jsonDecode(response.body);

        msg = jsonResponse['message'] ?? '';
        error = jsonResponse['error'] ?? '';

        final title = (response.statusCode == 200) ? 'Success' : 'Error';

        prefs.setString('phone', sendPone);
        if (sendMomo != null) prefs.setString('momo', sendMomo);
        if (code != null) prefs.setString('code', code!);
        if (name != null) prefs.setString('name', name!);
        if (email != '') prefs.setString('email', email);
        if (region != null) prefs.setString('region', region!);

        showPopupMessage(context, title, msg);
        print(msg);
      } else {
        String msg = "Veuillez remplir toutes les informations demandées.";
        String title = "Information incomplète.";
        showPopupMessage(context, title, msg);
        print(msg);
      }
    } catch (e) {
      print(e);
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> uploadAvatar({
    required BuildContext context,
    required String path,
  }) async {
    try {
      final url = Uri.parse('$uploadPP?email=$email');

      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['email'] = email;

      final avatarName = kIsWeb
          ? generateUniqueFileName('pp', 'jpg')
          : Uri.file(path).pathSegments.last;

      if (kIsWeb) {
        final fileBytes = base64.decode(path);

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: avatarName,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        String permanentPath = '';

        if (kIsWeb) {
          permanentPath = '${host}Profile Pictures/$email/$avatarName';
        } else {
          String folder = 'Profile Pictures';

          permanentPath = await saveFileLocally(folder, avatarName, path);
        }
        avatar = permanentPath;

        prefs.setString('avatar', permanentPath);

        setState(() {});
      } else {
        showPopupMessage(
          context,
          context.translate('error'), // 'Erreur'
          context.translate('error_occurred'), // 'An error occured please try again later'
        );
      }

      showSpinner = false;
    } catch (e) {
      String msg = e.toString();
      String title = context.translate('error'); // 'Error'
      showPopupMessage(context, title, msg);
      showSpinner = false;
    }
  }

  @override
  void initState() {
    super.initState();
    () async {
      await initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: context.translate('modify'), // 'Modifier'
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(25 * fem, 32 * fem, 25 * fem, 32 * fem),
        width: double.infinity,
        height: 1200,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(1 * fem, 0 * fem, 1 * fem, 15 * fem),
              width: double.infinity,
              child: id != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 122 * fem,
                                height: 122 * fem,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(61 * fem),
                                  border: Border.all(
                                    color: Color(0xffffffff),
                                    width: 2.0,
                                  ),
                                  color: Color(0xffc4c4c4),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: profileImage(avatar),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 7 * fem),
                                child: Text(
                                  email,
                                  style: SafeGoogleFont(
                                    'Montserrat',
                                    fontSize: 12 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3333333333 * ffem / fem,
                                    letterSpacing: 0.400000006 * fem,
                                    color: Color(0xff6d7d8b),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0 * fem,
                              ),
                              ReusableButton(
                                title: context.translate('modify_photo'), // 'Modifier Photo'
                                onPress: () async {
                                  try {
                                    final result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                    );

                                    if (result == null) return;

                                    List<int>? fileBytes =
                                        result.files.single.bytes;

                                    final filePath = kIsWeb
                                        ? base64.encode(fileBytes!)
                                        : result.files.first.path!;

                                    setState(() {
                                      showSpinner = true;
                                    });

                                    await uploadAvatar(
                                      context: context,
                                      path: filePath,
                                    );

                                    setState(() {
                                      showSpinner = false;
                                    });
                                  } on Exception {
                                    setState(() {
                                      showSpinner = false;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(fem, ffem, context.translate('name')), // 'Nom et Prénom'
                            CustomTextField(
                              hintText: context.translate('name_example'), // 'EX: Jean Michelle'
                              onChange: (val) {
                                name = val;
                              },
                              margin: 0,
                              value: name,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(fem, ffem, context.translate('whatsapp_number')), // 'Numero WhatsApp'
                            CustomTextField(
                              hintText: '',
                              onChange: (val) {
                                phone = val;
                              },
                              getCountryCode: (code) {
                                countryCode = code;
                              },
                              initialCountryCode: countryCode2,
                              margin: 0,
                              value: phone,
                              type: 5,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(fem, ffem, context.translate('sponsor_code')), // 'Code parrain'
                            CustomTextField(
                              hintText: '',
                              onChange: (val) {
                                code = val;
                              },
                              margin: 0,
                              value: code ?? '',
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(fem, ffem, context.translate('city')), // 'Ville'
                            CustomTextField(
                              hintText: '',
                              onChange: (val) {
                                region = val;
                              },
                              margin: 0,
                              value: region,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(fem, ffem, context.translate('momo_number')), // 'Numero MOMO/OM'
                            CustomTextField(
                              hintText: '',
                              onChange: (val) {
                                momo = val;
                              },
                              getCountryCode: (code) {
                                cCode = code;
                              },
                              initialCountryCode: cCode2,
                              margin: 0,
                              value: momo,
                              type: 5,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        ReusableButton(
                          title: context.translate('modify'), // 'Modifier'
                          lite: false,
                          onPress: () async {
                            try {
                              setState(() {
                                showSpinner = true;
                              });

                              await modifyUser();

                              setState(() {
                                showSpinner = false;
                              });
                            } catch (e) {
                              String msg = e.toString();
                              String title = context.translate('error'); // 'Error'
                              showPopupMessage(context, title, msg);
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          },
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        ReusableButton(
                          title: context.translate('modify_email'), // 'Modifier l\'adresse e-mail'
                          lite: false,
                          onPress: () async {
                            context.pushNamed(ModifyEmail.id);
                          },
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Container _label(double fem, double ffem, String title) {
    return Container(
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 7 * fem),
      child: Text(
        title,
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 12 * ffem,
          fontWeight: FontWeight.w500,
          height: 1.3333333333 * ffem / fem,
          letterSpacing: 0.400000006 * fem,
          color: Color(0xff6d7d8b),
        ),
      ),
    );
  }
}
