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
import 'package:flutter/services.dart' show rootBundle;
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/design/supscrition.dart';

import 'package:path_provider/path_provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:snipper_frontend/design/sponsor_info_page.dart';
import 'package:snipper_frontend/design/manage_subscription_page.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  static const id = 'profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool showSpinner = false;
  final ApiService apiService = ApiService();

  late SharedPreferences prefs;

  String telegramLink = 'https://t.me/+huMT6BLYR9sxOTg0';
  String whatsappLink = 'https://chat.whatsapp.com/IlGvSZtVYEkLRDFStFuQMT';

  bool isCibleSubscribed = false;

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

    List<String> activeSubscriptions =
        prefs.getStringList('activeSubscriptions') ?? [];
    isCibleSubscribed =
        activeSubscriptions.any((sub) => sub.toLowerCase() == 'cible');

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

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.apiReportedSuccess) {
        otp = response.body['data']?['otp']?.toString() ??
            response.body['otp']?.toString() ??
            '';
        if (otp.isEmpty) {
          print(
              "OTP request successful but OTP not found in response: $response");
          showPopupMessage(context, context.translate('error'),
              context.translate('otp_retrieval_failed'));
        }
      } else {
        String errorMsg = response.message;
        showPopupMessage(context, context.translate('error'), errorMsg);
        print(
            'API Error createContactsOTP: ${response.statusCode} - $errorMsg');
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
    final avatar = prefs.getString('avatar');

    setState(() {
      showSpinner = true;
    });

    try {
      final response = await apiService.logoutUser();

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.apiReportedSuccess) {
        await deleteFile(avatar ?? '');
        await prefs.clear();
        await deleteNotifications();
        await deleteAllKindTransactions();

        String msg = response.message.isNotEmpty
            ? response.message
            : context.translate('logged_out_successfully');
        String title = context.translate('logout');
        showPopupMessage(context, title, msg);
        if (mounted) context.go('/');
      } else {
        String errorMsg = response.message;
        showPopupMessage(context, context.translate('error'), errorMsg);
        print(
            'API Error logoutUser (Profile): ${response.statusCode} - $errorMsg');
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
      if (!mounted) return null;
      setState(() {
        showSpinner = true;
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final headers = {
          'Accept': 'text/vcard',
          'Content-Type': 'application/json',
        };
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }

        final uri = Uri.parse('${host}api/contacts/export');

        final response = await http.get(uri, headers: headers);
        final statusCode = response.statusCode;
        final String vcfDataString = response.body;

        if (statusCode >= 200 &&
            statusCode < 300 &&
            vcfDataString.isNotEmpty &&
            vcfDataString.trim().startsWith('BEGIN:VCARD')) {
          final timestamp =
              DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final fileName = 'sbc_contacts_profile_$timestamp.vcf';
          downloadFileWeb(vcfDataString, fileName);
          if (mounted) {
            showPopupMessage(context, context.translate('success'),
                context.translate('download_started'));
          }
        } else {
          String effectiveErrorMessage;
          if (!(statusCode >= 200 && statusCode < 300)) {
            effectiveErrorMessage =
                response.reasonPhrase ?? context.translate('network_error');
            print(
                'API Error downloadVCF (Web - HTTP Direct): $statusCode - ${response.reasonPhrase} - Body: ${vcfDataString.substring(0, (vcfDataString.length < 200 ? vcfDataString.length : 200))}');
          } else if (vcfDataString.isEmpty) {
            effectiveErrorMessage = context.translate('vcf_data_empty');
          } else {
            effectiveErrorMessage =
                context.translate('invalid_vcf_data_received');
            print(
                'Error: Invalid VCF data received (Web - HTTP Direct). Expected VCF, got: "${vcfDataString.substring(0, (vcfDataString.length < 200 ? vcfDataString.length : 200))}"');
          }

          if (mounted) {
            showPopupMessage(
                context, context.translate('error'), effectiveErrorMessage);
          }
        }
      } catch (e) {
        print('Exception in downloadVCF (Web - HTTP Direct): $e');
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
      return null;
    }

    if (!mounted) return null;
    setState(() {
      showSpinner = true;
    });
    String? permanentPath;

    try {
      final response = await apiService.exportContacts({});

      final statusCode = response.statusCode;
      final vcfData = response.body['data'] as String?;

      if (statusCode >= 200 &&
          statusCode < 300 &&
          response.apiReportedSuccess &&
          vcfData != null &&
          vcfData.isNotEmpty) {
        try {
          final vcfBytes = utf8.encode(vcfData);

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
        String errorMsg = response.message;
        if (vcfData == null || vcfData.isEmpty) {
          errorMsg = context.translate('vcf_data_empty');
        }
        showPopupMessage(context, context.translate('error'), errorMsg);
        print('API Error downloadVCF: ${response.statusCode} - $errorMsg');
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

    () async {
      await initSharedPref();
      setState(() {});
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
                                Icons.subscriptions,
                                context.translate('manage_subscription'),
                                () {
                                  context
                                      .pushNamed(ManageSubscriptionPage.id)
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
                                  if (isSubscribed && partnerPack != null) {
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
    final content = await rootBundle.loadString(vcfPath);
    return parseVcfContent(content);
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
        continue;
      }

      if (line.startsWith('FN')) {
        final realName = line.split(':')[1].replaceFirst(' SBC', '');
        contact.displayName = realName;
        contact.suffix = realName;
        contact.familyName = 'SBC';
      }

      if (line.startsWith('TEL')) {
        String phoneNumber = line.split(':')[1];
        contact.phones?.add(Item(label: 'mobile', value: phoneNumber));
      }

      if (line.startsWith('END:VCARD')) {
        contacts.add(contact);
        contact = null;
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
