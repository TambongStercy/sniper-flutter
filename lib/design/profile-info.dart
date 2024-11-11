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
import 'package:snipper_frontend/design/espace-partenaire.dart';
import 'package:snipper_frontend/design/profile-modify.dart';
import 'package:snipper_frontend/design/splash1.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/main.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

import 'package:path_provider/path_provider.dart';
import 'package:contacts_service/contacts_service.dart';

class Profile extends StatefulWidget {
  static const id = 'profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool showSpinner = false;

  late SharedPreferences prefs;

  String telegramLink = 'https://t.me/+huMT6BLYR9sxOTg0';
  String whatsappLink = 'https://chat.whatsapp.com/IlGvSZtVYEkLRDFStFuQMT';

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    name = prefs.getString('name');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    isPartner = prefs.getString('partnerPack') != null;

    telegramLink =
        prefs.getString('telegram') ?? 'https://t.me/+huMT6BLYR9sxOTg0';
    whatsappLink = prefs.getString('whatsapp') ??
        'https://chat.whatsapp.com/IlGvSZtVYEkLRDFStFuQMT';

    showSpinner = false;

    downloadUrl = '${downloadContacts}?email=$email';
    downloadUpdateUrl = '${downloadContactsUpdates}?email=$email';
  }

  Future<void> logoutUser() async {
    final email = prefs.getString('email');
    final token = prefs.getString('token');
    final avatar = prefs.getString('avatar');

    var regBody = {
      'email': email,
      'token': token,
    };

    await http.post(
      Uri.parse(logout),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(regBody),
    );

    await deleteFile(avatar ?? '');
    // await unInitializeOneSignal();
    prefs.setString('token', '');
    prefs.setString('id', '');
    prefs.setString('email', '');
    prefs.setString('name', '');
    prefs.setString('token', '');
    prefs.setString('region', '');
    prefs.setString('phone', '');
    prefs.setString('code', '');
    prefs.setString('avatar', '');
    prefs.setInt('balance', 0);
    prefs.setBool('isSubscribed', false);
    await deleteNotifications();
    await deleteAllKindTransactions();

    String msg = 'You where successfully logged out';
    String title = 'Logout';

    showPopupMessage(context, title, msg);

    context.go('/');
  }

  String? email;
  String? name;
  String? region;
  String? phone;
  String? token;
  String avatar = '';
  bool isSubscribed = false;
  bool isPartner = false;
  String downloadUrl = '';
  String downloadUpdateUrl = '';

  Future<String?> downloadVCF(BuildContext context) async {
    try {
      if (kIsWeb) {
        String msg =
            'Cette fonctionnalité n\'est pas encore disponible sur web.';
        String title = 'Erreur';
        showPopupMessage(context, title, msg);
        return null;
      }

      // print(token);
      // print(email);

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$downloadVcf?email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      final imageData = jsonResponse['vcfData'];
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        final imageBytes = base64Decode(imageData);
        if (kIsWeb) {
          return null;
        }
        print(imageData);
        // String fileName = generateUniqueFileName('pp', 'vcf');
        String fileName = 'contacts.vcf';
        String folder = 'VCF Files';

        final permanentPath =
            await saveFileBytesLocally(folder, fileName, imageBytes);

        return permanentPath;
      } else {
        String title = 'Error';
        showPopupMessage(context, title, msg);
        // Handle errors, e.g., image not found
        print('VCF request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
    return null;
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
    // double ffem = fem * 0.97;

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
                                'assets/assets/images/Certified - ${isPartner ? 'Orange' : 'Blue'}.png',
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
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${isSubscribed ? (isPartner ? context.translate('partner') : context.translate('subscriber')) : context.translate('user')} SBC',
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
                            context.pushNamed(ProfileMod.id).then((value) => refreshPage());

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
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Icon(Icons.phone_rounded),
                          title: Text(
                            context.translate('contacts'), // 'Contacts'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () async {
                            try {
                              if (isSubscribed) {
                                refreshPageWait();
                                if (kIsWeb) {
                                  launchURL(downloadUrl);
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
                                String msg = context.translate(
                                    'not_subscribed'); // 'Vous n\'êtes pas abonné😔'
                                String title =
                                    context.translate('error'); // 'Erreur'
                                showPopupMessage(context, title, msg);
                              }
                            } catch (e) {
                              String msg = context.translate(
                                  'error_occurred'); // 'An Error occured😥'
                              String title =
                                  context.translate('error'); // 'Error'
                              showPopupMessage(context, title, msg);
                              print(e);
                              refreshPageRemove();
                            }
                          },
                        ),
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
                          onTap: () async {
                            try {
                              if (isSubscribed) {
                                refreshPageWait();
                                if (kIsWeb) {
                                  launchURL(downloadUpdateUrl);
                                  refreshPageRemove();
                                } else {
                                  final path = await downloadVCF(context);

                                  refreshPageRemove();
                                  if (path == null) {
                                    return print('Error somewhere');
                                  }

                                  final contacts = await readVcfFile(path);
                                  await saveContacts(contacts);
                                }
                              } else {
                                String msg = context.translate(
                                    'not_subscribed'); // 'Vous n\'êtes pas abonné😔'
                                String title =
                                    context.translate('error'); // 'Erreur'
                                showPopupMessage(context, title, msg);
                              }
                            } catch (e) {
                              String msg = context.translate(
                                  'error_occurred'); // 'An Error occured😥'
                              String title =
                                  context.translate('error'); // 'Error'
                              showPopupMessage(context, title, msg);
                              print(e);
                              refreshPageRemove();
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 40.0),
                          leading: Icon(Icons.handshake),
                          title: Text(
                            context.translate(
                                'partner_space'), // 'Espace partenaire'
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff212121),
                            ),
                          ),
                          onTap: () {
                            if (isSubscribed && isPartner) {
                              context.pushNamed(EspacePartenaire.id);
                            } else {
                              String msg = context.translate(
                                  'not_partner'); // 'Vous n\'etes pas partenaire😔'
                              String title =
                                  context.translate('error'); // 'Erreur'
                              showPopupMessage(context, title, msg);
                            }
                          },
                        ),
                        Divider(),
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
                              launchURL(whatsappLink);
                            } else {
                              String msg = context.translate(
                                  'not_subscribed'); // 'Vous n\'etes pas abonné😔'
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
                              launchURL(telegramLink);
                            } else {
                              String msg = context.translate(
                                  'not_subscribed'); // 'Vous n\'etes pas abonné😔'
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
                                  'not_subscribed'); // 'Vous n\'etes pas abonné😔'
                              String title =
                                  context.translate('error'); // 'Erreur'
                              showPopupMessage(context, title, msg);
                            }
                          },
                        ),
                        SizedBox(height: 20),
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
}
