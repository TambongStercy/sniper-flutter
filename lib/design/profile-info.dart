import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/affiliation-page.dart';
import 'package:snipper_frontend/design/contact-update.dart';
import 'package:snipper_frontend/design/espace-partenaire.dart';
import 'package:snipper_frontend/design/profile-modify.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/main.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/utils.dart';
// import 'package:http/http.dart' as http; // Remove http import
import 'package:flutter/services.dart' show rootBundle;
import 'package:snipper_frontend/api_service.dart'; // Import ApiService
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'; // Added import for ModalProgressHUD

import 'package:path_provider/path_provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:snipper_frontend/design/sponsor_info_page.dart'; // Import the new sponsor page

class Profile extends StatefulWidget {
  static const id = 'profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool showSpinner = false;
  final ApiService apiService = ApiService(); // Instantiate ApiService

  late SharedPreferences prefs;

  String telegramLink = 'https://t.me/+huMT6BLYR9sxOTg0';
  String whatsappLink = 'https://chat.whatsapp.com/IlGvSZtVYEkLRDFStFuQMT';

  // Add state variable for subscription type
  bool isCibleSubscribed = false;

  // Add state variables for dynamic URLs
  String? dynamicTelegramUrl;
  String? dynamicWhatsappUrl;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    partnerPack = prefs.getString('partnerPack');
    name = prefs.getString('name');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    // Determine subscription type from activeSubscriptions list
    List<String> activeSubscriptions =
        prefs.getStringList('activeSubscriptions') ?? [];
    // Check if the list contains 'cible' (adjust key if necessary)
    isCibleSubscribed =
        activeSubscriptions.any((sub) => sub.toLowerCase() == 'cible');

    // Load dynamic URLs from App Settings
    dynamicTelegramUrl = prefs.getString('appSettings_telegramUrl');
    dynamicWhatsappUrl = prefs.getString('appSettings_whatsappUrl');

    telegramLink =
        prefs.getString('telegram') ?? 'https://t.me/+huMT6BLYR9sxOTg0';
    whatsappLink = prefs.getString('whatsapp') ??
        'https://chat.whatsapp.com/IlGvSZtVYEkLRDFStFuQMT';

    showSpinner = false;

    downloadUrl = '${downloadContacts}?email=$email';
    downloadUpdateUrl = '${downloadContactsUpdates}?email=$email';
  }

  Future<String> createContactsOTP(BuildContext context) async {
    setState(() {
      showSpinner = true;
    });
    String otp = '';
    try {
      final response = await apiService.requestContactsExportOtp();

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        // Adjust key based on actual API response structure for the OTP
        otp = response['data']?['otp']?.toString() ??
            response['otp']?.toString() ??
            '';
        if (otp.isEmpty) {
          print(
              "OTP request successful but OTP not found in response: $response");
          showPopupMessage(context, context.translate('error'),
              context.translate('otp_retrieval_failed'));
        }
      } else {
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('otp_request_failed');
        showPopupMessage(context, context.translate('error'), errorMsg);
        print(
            'API Error createContactsOTP: ${response['statusCode']} - $errorMsg');
      }
    } catch (e) {
      String title = context.translate('error');
      String message =
          context.translate('error_occurred') + ': ${e.toString()}';
      showPopupMessage(context, title, message);
      print('Exception in createContactsOTP: $e');
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
    return otp;
  }

  Future<void> logoutUser() async {
    // final email = prefs.getString('email'); // Not needed
    // final token = prefs.getString('token'); // Handled by ApiService
    final avatar = prefs.getString('avatar');

    setState(() {
      showSpinner = true;
    });

    try {
      final response = await apiService.logoutUser();

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        await deleteFile(avatar ?? '');
        await prefs.clear(); // Clear all prefs on successful logout
        await deleteNotifications();
        await deleteAllKindTransactions();

        String msg =
            response['message'] ?? context.translate('logged_out_successfully');
        String title = context.translate('logout');
        // Show message *before* navigation might be better UX
        showPopupMessage(context, title, msg);
        if (mounted) context.go('/');
      } else {
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('logout_failed');
        showPopupMessage(context, context.translate('error'), errorMsg);
        print(
            'API Error logoutUser (Profile): ${response['statusCode']} - $errorMsg');
      }
    } catch (e) {
      print('Exception in logoutUser (Profile): $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  String? email;
  String? name;
  String? region;
  String? phone;
  String? token;
  String avatar = '';
  bool isSubscribed = false;
  String? partnerPack;
  String downloadUrl = '';
  String downloadUpdateUrl = '';

  Future<String?> downloadVCF(BuildContext context) async {
    if (kIsWeb) {
      // Web-specific download logic, similar to contact-update.dart
      if (!mounted) return null;
      setState(() {
        showSpinner = true;
      });
      try {
        final response = await apiService.exportContacts({}); // No filters
        final statusCode = response['statusCode'];
        final vcfData = response['data'];

        if (statusCode != null &&
            statusCode >= 200 &&
            statusCode < 300 &&
            vcfData is String &&
            vcfData.isNotEmpty) {
          final timestamp = formatDateString(
            DateTime.now().toString(),
            pattern: 'yyyyMMdd_HHmmss',
          );
          final fileName = 'sbc_contacts_profile_$timestamp.vcf';
          downloadFileWeb(vcfData,
              fileName); // Assumes downloadFileWeb is globally accessible or in utils
          if (mounted) {
            showPopupMessage(context, context.translate('success'),
                context.translate('download_started'));
          }
        } else {
          String errorMsg = response['message'] ??
              response['error'] ??
              context.translate('vcf_download_failed');
          if (vcfData == null || (vcfData is String && vcfData.isEmpty)) {
            errorMsg = context.translate('vcf_data_empty');
          }
          if (mounted) {
            showPopupMessage(context, context.translate('error'), errorMsg);
          }
          print(
              'API Error downloadVCF (Web - Profile): ${response['statusCode']} - $errorMsg');
        }
      } catch (e) {
        print('Exception in downloadVCF (Web - Profile): $e');
        if (mounted) {
          showPopupMessage(context, context.translate('error'),
              context.translate('error_occurred'));
        }
      } finally {
        if (mounted) {
          setState(() {
            showSpinner = false;
          });
        }
      }
      return null; // No local path for web downloads
    }

    // Existing mobile download logic starts here
    if (!mounted) return null; // Check mounted for mobile path too
    setState(() {
      showSpinner = true;
    });
    String? permanentPath;

    try {
      // Call ApiService.exportContacts - pass empty filters for now
      // If filters are needed based on UI, pass them here.
      final response = await apiService.exportContacts({});

      final statusCode = response['statusCode'];
      final vcfData = response['data']; // Data is expected to be raw VCF string

      if (statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300 &&
          vcfData is String &&
          vcfData.isNotEmpty) {
        try {
          // Decode VCF data (it might be base64 encoded or plain text)
          // Assuming plain text based on exportContacts implementation detail
          // If it's base64, uncomment the decode line
          // final vcfBytes = base64Decode(vcfData);
          final vcfBytes = utf8.encode(vcfData); // Encode plain string to bytes

          String fileName = 'contacts.vcf';
          String folder = 'VCF Files';
          permanentPath =
              await saveFileBytesLocally(folder, fileName, vcfBytes);
          print("VCF file saved to: $permanentPath");
        } catch (e) {
          print("Error processing/saving VCF data: $e");
          showPopupMessage(context, context.translate('error'),
              context.translate('vcf_processing_error'));
          permanentPath = null;
        }
      } else {
        // Handle API or data error
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('vcf_download_failed');
        if (vcfData == null || (vcfData is String && vcfData.isEmpty)) {
          errorMsg = context.translate('vcf_data_empty');
        }
        showPopupMessage(context, context.translate('error'), errorMsg);
        print('API Error downloadVCF: ${response['statusCode']} - $errorMsg');
      }
    } catch (e) {
      print('Exception in downloadVCF: $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
    return permanentPath;
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

  refreshPage() {
    if (mounted) {
      setState(() {
        showSpinner = false;
        initSharedPref();
      });
    }
  }

  refreshPageRemove() {
    if (mounted) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  refreshPageWait() {
    if (mounted) {
      setState(() {
        showSpinner = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('profile'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Row(
              children: [
                Icon(Icons.language, color: Colors.black),
                Text(
                  Localizations.localeOf(context).languageCode.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
            onPressed: () {
              // Toggle between English and French
              Locale newLocale =
                  Localizations.localeOf(context).languageCode == 'en'
                      ? Locale('fr')
                      : Locale('en');
              MyApp.setLocale(context, newLocale);
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: downloadUrl != '' && downloadUpdateUrl != ''
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: profileImage(
                                          prefs.getString('avatarId'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isSubscribed)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Image.asset(
                                        'assets/assets/images/Certified - ${isCibleSubscribed ? 'Orange' : 'Blue'}.png',
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                capitalizeWords(name ?? ''),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isSubscribed ? (isCibleSubscribed ? context.translate('cible_subscriber') : context.translate('classique_subscriber')) : context.translate('user')} SBC',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Profile Menu Items
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                context,
                                Icons.person,
                                context.translate('modify_profile'),
                                () {
                                  context
                                      .pushNamed(ProfileMod.id)
                                      .then((value) => refreshPage());
                                },
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                Icons.people_rounded,
                                context.translate('affiliation'),
                                () {
                                  context.pushNamed(Affiliation.id);
                                },
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                Icons.person_pin_rounded,
                                context.translate('sponsor_info_title'),
                                () {
                                  context.pushNamed(SponsorInfoPage.id);
                                },
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                Icons.phone_rounded,
                                context.translate('contacts'),
                                () async {
                                  if (!isSubscribed) {
                                    showPopupMessage(
                                        context,
                                        context.translate('error'),
                                        context.translate('not_subscribed'));
                                    return;
                                  }
                                  await downloadVCF(context);
                                },
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                Icons.person_pin_rounded,
                                context.translate('partner_space'),
                                () {
                                  if (!isSubscribed && partnerPack != null) {
                                    context.pushNamed(EspacePartenaire.id);
                                  } else {
                                    showPopupMessage(
                                        context,
                                        context.translate('error'),
                                        context.translate('not_subscribed'));
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                context,
                                Icons.settings_phone_rounded,
                                context.translate('update_contacts'),
                                () {
                                  if (isSubscribed) {
                                    context.pushNamed(ContactUpdate.id);
                                  } else {
                                    showPopupMessage(
                                        context,
                                        context.translate('error'),
                                        context.translate('not_subscribed'));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Social Media Links
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSocialMenuItem(
                                context,
                                'assets/assets/images/Whatsapp.png',
                                context.translate('join_sbc_community'),
                                () {
                                  if (isSubscribed) {
                                    final urlToLaunch =
                                        dynamicWhatsappUrl ?? whatsappLink;
                                    if (urlToLaunch != null &&
                                        urlToLaunch.isNotEmpty) {
                                      launchURL(urlToLaunch);
                                    } else {
                                      showPopupMessage(
                                          context,
                                          context.translate('error'),
                                          context
                                              .translate('link_not_available'));
                                    }
                                  } else {
                                    showPopupMessage(
                                        context,
                                        context.translate('error'),
                                        context.translate('not_subscribed'));
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              _buildSocialMenuItem(
                                context,
                                'assets/assets/images/telegram.png',
                                context.translate('join_trading_training'),
                                () {
                                  if (isSubscribed) {
                                    final urlToLaunch =
                                        dynamicTelegramUrl ?? telegramLink;
                                    if (urlToLaunch != null &&
                                        urlToLaunch.isNotEmpty) {
                                      launchURL(urlToLaunch);
                                    } else {
                                      showPopupMessage(
                                          context,
                                          context.translate('error'),
                                          context
                                              .translate('link_not_available'));
                                    }
                                  } else {
                                    showPopupMessage(
                                        context,
                                        context.translate('error'),
                                        context.translate('not_subscribed'));
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              _buildSocialMenuItem(
                                context,
                                'assets/assets/images/telegram.png',
                                context.translate('marketing_360'),
                                () {
                                  if (isSubscribed) {
                                    launchURL('https://t.me/+BLBOGqPGjSwwNmE0');
                                  } else {
                                    showPopupMessage(
                                        context,
                                        context.translate('error'),
                                        context.translate('not_subscribed'));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });
                                await logoutUser();
                              } catch (e) {
                                setState(() {
                                  showSpinner = false;
                                });
                                showPopupMessage(
                                    context,
                                    context.translate('error'),
                                    context.translate('error_occurred'));
                                print(e);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              context.translate('logout'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Footer
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              context.translate('developed_by_simbtech'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  int contactsLength = 0;
  int percSaved = 0;

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }

  Future<String> getVcfFilePath() async {
    // Get the directory where you can store the VCF file
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String vcfPath = '${appDocDir.path}/contacts.vcf';
    return vcfPath;
  }

  Future<List<Contact>> readVcfFile(String vcfPath) async {
    File file = File(vcfPath);
    if (await file.exists()) {
      String content = await file.readAsString();
      return parseVcfContent(content);
    } else {
      throw Exception('VCF file not found');
    }
  }

  Future<List<Contact>> readVcfFileFromAsset(String vcfPath) async {
    // as Uint8List ;
    // File file = File(vcfPath);

    final content = await rootBundle.loadString(vcfPath);
    // String content = await file.readAsString();
    return parseVcfContent(content);
    // if (await file.exists()) {
    // } else {
    //   throw Exception('VCF file not found');
    // }
  }

  List<Contact> parseVcfContent(String content) {
    List<Contact> contacts = [];
    List<String> lines = LineSplitter.split(content).toList();
    Contact? contact;

    for (String line in lines) {
      if (line.startsWith('BEGIN:VCARD')) {
        contact = Contact();
        contact.phones = [];
        contact.displayName = '';
        continue;
      }

      if (contact == null) {
        // Skip lines if 'BEGIN:VCARD' is not encountered
        continue;
      }

      if (line.startsWith('FN')) {
        // Parse display name
        final realName = line.split(':')[1].replaceFirst(' SBC', '');
        contact.displayName = realName;
        contact.suffix = realName;
        contact.familyName = 'SBC';
      }

      if (line.startsWith('TEL')) {
        // Parse phone number
        String phoneNumber = line.split(':')[1];
        contact.phones?.add(Item(label: 'mobile', value: phoneNumber));
      }

      if (line.startsWith('END:VCARD')) {
        contacts.add(contact);
        contact = null; // Reset contact after adding to the list
      }
    }

    return contacts;
  }

  Future<void> saveContacts(List<Contact> importedContacts) async {
    percSaved = 0;
    contactsLength = importedContacts.length;

    showLoaderDialog(context);

    final isGranted = await requestContactPermission();

    if (!isGranted) {
      context.pop();
      String msg = 'L\'access a vos contacts a ete refuser';
      String title = 'Erreur';
      showPopupMessage(context, title, msg);
      return;
    }

    print('SBC contacts saving....');
    for (Contact contact in importedContacts) {
      percSaved++;
      await ContactsService.addContact(contact);
    }

    context.pop();

    String msg =
        'Les $contactsLength contacts de la SBC ont été enregistrés avec succès san répétition.';
    String title = 'Félicitations 🥳';
    showPopupMessage(context, title, msg);
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text('Enregistrement des contacts'),
      content: Container(
        height: 70,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 0),
              child: Text('Cela peut prendre près d\'une minute ou plus.'),
            ),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSocialMenuItem(
      BuildContext context, String iconPath, String title, VoidCallback onTap) {
    return ListTile(
      leading: Image.asset(
        iconPath,
        width: 24,
        height: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
