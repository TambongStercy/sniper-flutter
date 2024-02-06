// ignore_for_file: sort_child_properties_last
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/accueil.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/utils.dart';

class PpUpload extends StatefulWidget {
  const PpUpload({super.key});

  static const String id = 'upload_profile_picture';

  @override
  State<PpUpload> createState() => _PpUploadState();
}

class _PpUploadState extends State<PpUpload> {
  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  String? email;
  String? token;
  String avatar = '';
  bool isSubscribed = false;

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
        String fileName = generateUniqueFileName('pp','jpg');
        // String fileName = 'Your Picture.jpg';
        String folder = 'Profile Pictures';

        final permanentPath = await saveFileLocally(folder, fileName, path);

        avatar = permanentPath;

        prefs.setString('avatar', permanentPath);

        print(avatar);

        setState(() {});
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
    initSharedPref();
    super.initState();
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Color(0xffffffff),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          25 * fem, 0 * fem, 0 * fem, 21.17 * fem),
                      width: 771.27 * fem,
                      height: 275.83 * fem,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 60.0,
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
                              'Photo de profil',
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
                              'Veuillez fournir une photo pour votre profil.',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 100.0,
                          width: double.infinity,
                        ),
                        SizedBox(
                          child: InkWell(
                            onTap: () async {
                              try {
                                final result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                );

                                if (result == null) return;

                                setState(() {
                                  showSpinner = true;
                                });

                                final filePath = result.files.first.path!;

                                print('filePath : $filePath');

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
                            child: CircleAvatar(
                              radius: 100.0,
                              child: !ppExist(avatar)
                                  ? const Icon(
                                      Icons.photo_camera_rounded,
                                      color: Colors.grey,
                                      size: 120.0,
                                    )
                                  : null,
                              backgroundImage: _profileImage(),
                              backgroundColor: Colors.blueGrey[100],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            !ppExist(avatar) ? 'Passer' : 'Suivant',
                            style: TextStyle(fontSize: 17.0),
                          ),
                        ),
                        onPressed: () {
                          isSubscribed
                              ? Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Accueil(),
                                  ),
                                  (route) => false,
                                )
                              : Navigator.pushNamed(
                                  context,
                                  Subscrition.id,
                                );
                        },
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

  ImageProvider<Object>? _profileImage() {
    if (ppExist(avatar)) {
      // Check if the user's profile picture path is not empty and the file exists.
      return FileImage(File(avatar));
    }
    // Return the default profile picture from the asset folder.
    return null;
  }
}
