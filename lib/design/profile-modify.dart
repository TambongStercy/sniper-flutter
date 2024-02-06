import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;

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
    email = prefs.getString('email');
    name = prefs.getString('name');
    region = prefs.getString('region');
    code = prefs.getString('code');
    phone = prefs.getString('phone') ?? '';
    avatar = prefs.getString('avatar') ?? "";

    print(phone);
    print(code);
    print(token);
    print(region);

    final country = getCountryFromPhoneNumber(phone);

    countryCode = country!.dialCode;
    countryCode2 = country.code;
    print('uououououo');
    print(countryCode);
    print(countryCode2);
    print('uououououo');
    phone = phone.substring(country.dialCode.length);

    print(countryCode);

    showSpinner = false;
  }

  String? id;
  String? email;
  String? name;
  String? region;
  String phone = '';
  String? token;
  String? code;
  String avatar = '';
  String countryCode = '237';
  String countryCode2 = 'CM';

  Future<void> modifyUser(context) async {
    try {
      if (email!.isNotEmpty &&
          name!.isNotEmpty &&
          region!.isNotEmpty &&
          phone.isNotEmpty &&
          code!.isNotEmpty) {
        final regBody = {
          'id': id,
          'email': email,
          'name': name,
          'region': region,
          'phone': phone,
          'code': code,
          'token': token,
        };

        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        await http.post(
          Uri.parse(update),
          headers: headers,
          body: jsonEncode(regBody),
        );

        const msg = 'modifications completed successfully';
        const title = 'Success';

        final sendPone = countryCode + phone;

        prefs.setString('phone', sendPone);
        code != null ? prefs.setString('code', code!) : print('');
        name != null ? prefs.setString('name', name!) : print('');
        email != null ? prefs.setString('email', email!) : print('');
        region != null ? prefs.setString('region', region!) : print('');

        showPopupMessage(context, title, msg);
        print(msg);
      } else {
        String msg = 'Please fill in all information asked';
        String title = 'Information not complete';
        showPopupMessage(context, title, msg);
        print(msg);
      }
    } catch (e) {
      String msg = e.toString();
      String title = 'Error';
      print(msg);
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
      request.fields['email'] = email!;

      request.files.add(await http.MultipartFile.fromPath('file', path));

      final response = await request.send();

      if (response.statusCode == 200) {
        String fileName = generateUniqueFileName('pp', 'jpg');
        String folder = 'Profile Pictures';

        final permanentPath = await saveFileLocally(folder, fileName, path);

        await deleteFile(avatar);

        avatar = permanentPath;
        prefs.setString('avatar', permanentPath);
      } else {
        print('request failed with status: ${response.statusCode}');
        // ignore: use_build_context_synchronously
        showPopupMessage(
          context,
          'Error',
          'An error occured please try again later',
        );
      }

      showSpinner = false;
    } catch (e) {
      String msg = e.toString();
      String title = 'Error';
      showPopupMessage(context, title, msg);
      print(e);
      showSpinner = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Create anonymous function:
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
    // showSpinner = false;

    print(email);
    return SimpleScaffold(
      title: 'Modifier',
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(25 * fem, 32 * fem, 25 * fem, 32 * fem),
        width: double.infinity,
        height: 1100,
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
                              SizedBox(
                                height: 20.0 * fem,
                              ),
                              ReusableButton(
                                title: 'Modifier Photo',
                                onPress: () async {
                                  try {
                                    final result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                    );

                                    if (result == null) return;

                                    final filePath = result.files.first.path!;

                                    print('filePath : $filePath');

                                    setState(() {
                                      showSpinner = true;
                                    });

                                    // ignore: use_build_context_synchronously
                                    await uploadAvatar(
                                      context: context,
                                      path: filePath,
                                    );

                                    setState(() {
                                      showSpinner = false;
                                    });
                                  } on Exception catch (e) {
                                    print(e);
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
                            _label(fem, ffem, 'Nom et Prenom'),
                            CustomTextField(
                              hintText: 'EX: Jean Michelle',
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
                            _label(fem, ffem, 'Email'),
                            CustomTextField(
                              hintText: '',
                              onChange: (val) {
                                email = val;
                              },
                              margin: 0,
                              value: email,
                              type: 4,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15 * fem,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(fem, ffem, 'Numero WhatsApp'),
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
                            _label(fem, ffem, 'Code parrain'),
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
                            _label(fem, ffem, 'Ville'),
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
                        ReusableButton(
                          title: 'Modifier',
                          lite: false,
                          onPress: () async {
                            try {
                              setState(() {
                                showSpinner = true;
                              });

                              await modifyUser(context);

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
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Container _label(double fem, double ffem, title) {
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
