import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension
import 'package:snipper_frontend/api_service.dart'; // Import ApiService

class PpUpload extends StatefulWidget {
  const PpUpload({super.key});

  static const String id = 'upload_profile_picture';

  @override
  State<PpUpload> createState() => _PpUploadState();
}

class _PpUploadState extends State<PpUpload> {
  bool showSpinner = false;
  final ApiService apiService = ApiService(); // Instantiate ApiService

  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email') ?? '';
    avatar = prefs.getString('avatarId') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  String email = '';
  String? token;
  String avatar = '';
  bool isSubscribed = false;

  Future<void> uploadAvatar({
    required BuildContext context,
    required String path,
  }) async {
    setState(() {
      showSpinner = true;
    });

    try {
      // Determine filename
      final fileName = kIsWeb
          ? generateUniqueFileName('pp', 'jpg') // Use existing util
          : Uri.file(path).pathSegments.last;

      // Call ApiService method
      final response = await apiService.uploadAvatar(path, fileName);

      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300 && response.apiReportedSuccess) {
        // Assuming the API returns the new URL in 'data' or 'imageUrl' or similar
        // Adjust the key based on the actual response structure from apiService.uploadAvatar
        final String? newAvatarUrl = response.body['data']?['avatarUrl'] ??
            response.body['imageUrl'] ??
            response.body['imgaeUrl'];

        if (newAvatarUrl != null) {
          avatar = newAvatarUrl;
          await prefs.setString('avatar', newAvatarUrl);
          print("Avatar updated successfully: $newAvatarUrl");
          setState(() {}); // Update UI to show new avatar
        } else {
          print(
              "API Success, but new avatar URL not found in response: $response");
          showPopupMessage(
            context,
            context.translate('error'),
            context
                .translate('upload_success_no_url'), // Add this translation key
          );
        }
      } else {
        // Handle API error response
        String errorMsg = response.message;
        showPopupMessage(
          context,
          context.translate('error'),
          errorMsg,
        );
        print(
            'API Error uploadAvatar UI: ${response.statusCode} - $errorMsg');
      }
    } catch (e) {
      String msg = e.toString();
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
      print('Exception in uploadAvatar UI: $e');
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  bool ppExist(String avatarUrl) {
    return avatarUrl.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    () async {
      await initSharedPref();
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                  context.translate('profile_photo'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.translate('provide_profile_photo'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // Profile photo upload section
                Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          try {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );

                            if (result == null) return;

                            setState(() {
                              showSpinner = true;
                            });

                            List<int>? fileBytes = result.files.single.bytes;

                            final filePath = kIsWeb
                                ? base64.encode(fileBytes!)
                                : result.files.first.path!;

                            await uploadAvatar(
                              context: context,
                              path: filePath,
                            );
                          } catch (e) {
                            setState(() {
                              showSpinner = false;
                            });
                            print('Error selecting image: $e');
                          }
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: !ppExist(avatar)
                                ? Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey[500],
                                    size: 64,
                                  )
                                : ClipOval(
                                    child: Image(image: profileImage(avatar)),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        !ppExist(avatar)
                            ? context.translate('tap_to_upload')
                            : context.translate('tap_to_change'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isSubscribed) {
                        context.go('/');
                      } else {
                        context.goNamed(Subscrition.id);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        !ppExist(avatar)
                            ? context.translate('skip')
                            : context.translate('next'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
