import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/affiliation-page.dart';
import 'package:snipper_frontend/design/contact-update.dart';
import 'package:snipper_frontend/design/profile-modify.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/main.dart';
import 'package:snipper_frontend/utils.dart';
// import 'package:http/http.dart' as http; // Remove http import
import 'package:flutter/services.dart' show rootBundle;
import 'package:snipper_frontend/api_service.dart'; // Import ApiService

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
  String downloadUrl = '';
  String downloadUpdateUrl = '';

  Future<String?> downloadVCF(BuildContext context) async {
      if (kIsWeb) {
      showPopupMessage(context, context.translate('error'),
          context.translate('feature_not_available_web'));
        return null;
      }

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
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    var onTap = () async {
      try {
        if (isSubscribed) {
          refreshPageWait();
          if (kIsWeb) {
            final otp = await createContactsOTP(context);
            launchURL('$downloadUrl&otp=$otp');
            refreshPageRemove();
          } else {
            final path = await downloadVCF(context);

            print(path);

            refreshPageRemove();
            if (path == null) {
              return print('Error somewhere');
            }

            final contacts = await readVcfFile(path);
            await saveContacts(contacts);
          }
        } else {
          String msg = context
              .translate('not_subscribed'); // 'Vous n\'êtes pas abonné😔'
          String title = context.translate('error'); // 'Erreur'
          showPopupMessage(context, title, msg);
        }
      } catch (e) {
        String msg =
            context.translate('error_occurred'); // 'An Error occured😥'
        String title = context.translate('error'); // 'Error'
        showPopupMessage(context, title, msg);
        print(e);
        refreshPageRemove();
      }
    };
    return SimpleScaffold(
      actions: [
        IconButton(
          icon: Row(
            children: [
              Icon(Icons.language),
              Text(
                Localizations.localeOf(context).languageCode.toUpperCase(),
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
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
      title: context.translate('profile'), // 'Profile'
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(0 * fem, 15 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        child: downloadUrl != '' && downloadUpdateUrl != ''
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 102 * fem,
                            height: 102 * fem,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(61 * fem),
                              color: Color(0xffc4c4c4),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: profileImage(avatar),
                              ),
                            ),
                          ),
                          if (isSubscribed)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Image.asset(
                                'assets/assets/images/Certified - ${isCibleSubscribed ? 'Orange' : 'Blue'}.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeWords(name),
                            style: SafeGoogleFont(
                              'Montserrat',
                              letterSpacing: 0.0 * fem,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${isSubscribed ? (isCibleSubscribed ? context.translate('cible_subscriber') : context.translate('classique_subscriber')) : context.translate('user')} SBC',
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: Color(0xff25313c),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Icon(Icons.person),
                          title: Text(
                            context.translate(
                                'modify_profile'), // 'Modifier profil'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () {
                            context
                                .pushNamed(ProfileMod.id)
                                .then((value) => refreshPage());
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Icon(Icons.people_rounded),
                          title: Text(
                            context.translate('affiliation'), // 'Affiliation'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () {
                            context.pushNamed(Affiliation.id);
                          },
                        ),
                        // Re-add the Sponsor Info tile without the if condition
                        _buildListTile(
                          context,
                          fem,
                          ffem,
                          Icons.person_pin_rounded, // Icon for sponsor
                          context.translate(
                              'sponsor_info_title'), // Use existing translation
                          () {
                            context.pushNamed(SponsorInfoPage.id);
                          },
                        ),
                        // ListTile(
                        //   contentPadding: EdgeInsets.symmetric(
                        //       vertical: 5.0, horizontal: 40.0),
                        //   leading: Icon(Icons.phone_rounded),
                        //   title: Text(
                        //     context.translate('contacts'), // 'Contacts'
                        //     style: SafeGoogleFont(
                        //       'Montserrat',
                        //       fontSize: 15,
                        //       fontWeight: FontWeight.w400,
                        //       color: Color(0xff212121),
                        //     ),
                        //   ),
                        //   onTap: onTap,
                        // ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Icon(Icons.settings_phone_rounded),
                          title: Text(
                            context.translate(
                                'update_contacts'), // 'Mise a jour contacts'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () {
                            if (isSubscribed) {
                              context.pushNamed(ContactUpdate.id);
                            } else {
                              String msg = context.translate(
                                  'not_subscribed'); // 'Vous n\'êtes pas abonné😔'
                              String title =
                                  context.translate('error'); // 'Erreur'
                              showPopupMessage(context, title, msg);
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Image.asset(
                            'assets/assets/images/Whatsapp.png',
                            width: 23,
                            height: 23,
                          ),
                          title: Text(
                            context.translate(
                                'join_sbc_community'), // 'Rejoindre la Communauté SBC'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () {
                            if (isSubscribed) {
                              final urlToLaunch = dynamicWhatsappUrl ??
                                  whatsappLink; // Use dynamic URL first
                              if (urlToLaunch != null &&
                                  urlToLaunch.isNotEmpty) {
                                launchURL(urlToLaunch);
                              } else {
                                showPopupMessage(
                                    context,
                                    context.translate('error'),
                                    context.translate(
                                        'link_not_available')); // Add translation
                              }
                            } else {
                              String msg = context.translate(
                                  'not_subscribed'); // 'Vous n'etes pas abonné😔'
                              String title =
                                  context.translate('error'); // 'Erreur'
                              showPopupMessage(context, title, msg);
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Image.asset(
                            'assets/assets/images/telegram.png',
                            width: 23,
                            height: 23,
                          ),
                          title: Text(
                            context.translate(
                                'join_trading_training'), // 'Rejoindre la Formation en Trading'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () {
                            if (isSubscribed) {
                              final urlToLaunch = dynamicTelegramUrl ??
                                  telegramLink; // Use dynamic URL first
                              if (urlToLaunch != null &&
                                  urlToLaunch.isNotEmpty) {
                                launchURL(urlToLaunch);
                              } else {
                                showPopupMessage(
                                    context,
                                    context.translate('error'),
                                    context.translate(
                                        'link_not_available')); // Add translation
                              }
                            } else {
                              String msg = context.translate(
                                  'not_subscribed'); // 'Vous n'etes pas abonné😔'
                              String title =
                                  context.translate('error'); // 'Erreur'
                              showPopupMessage(context, title, msg);
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Image.asset(
                            'assets/assets/images/telegram.png',
                            width: 23,
                            height: 23,
                          ),
                          title: Text(
                            context
                                .translate('marketing_360'), // 'MARKETING 360°'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () {
                            if (isSubscribed) {
                              launchURL('https://t.me/+BLBOGqPGjSwwNmE0');
                            } else {
                              String msg = context.translate(
                                  'not_subscribed'); // 'Vous n'etes pas abonné😔'
                              String title =
                                  context.translate('error'); // 'Erreur'
                              showPopupMessage(context, title, msg);
                            }
                          },
                        ),

                        Divider(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.0 * fem,
                  ),
                  ReusableButton(
                    title: context.translate('logout'), // 'Deconnexion'
                    onPress: () async {
                      try {
                        setState(() {
                          showSpinner = true;
                        });

                        await logoutUser();

                        setState(() {
                          showSpinner = false;
                        });

                        String msg = context.translate(
                            'logged_out_successfully'); // 'You were successfully logged out'
                        String title = context.translate('logout'); // 'Logout'
                        showPopupMessage(context, title, msg);
                      } catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        String msg = context.translate(
                            'error_occurred'); // 'An Error has occurred please try again'
                        String title = context.translate('error'); // 'Error'
                        showPopupMessage(context, title, msg);
                        print(e);
                      }
                    },
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 0 * fem),
                    width: 339 * fem,
                    height: 50 * fem,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(7 * fem),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3f25313c),
                          offset: Offset(0 * fem, 0 * fem),
                          blurRadius: 2.1500000954 * fem,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        context.translate(
                            'developed_by_simbtech'), // 'Developpé par Simbtech\n copyright ©'
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 12 * fem,
                          fontWeight: FontWeight.w500,
                          height: 1.3333333333 * fem / fem,
                          letterSpacing: 0.400000006 * fem,
                          color: Color(0xff25313c),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
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

  Widget _buildListTile(BuildContext context, double fem, double ffem,
      IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 40.0),
      leading: Icon(icon),
      title: Text(
        title,
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xff212121),
        ),
      ),
      onTap: onTap,
    );
  }
}
