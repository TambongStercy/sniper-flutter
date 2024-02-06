import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/profilebutton.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/affiliation-page.dart';
import 'package:snipper_frontend/design/profile-modify.dart';
import 'package:snipper_frontend/design/splash1.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
// import 'package:contacts_service/contacts_service.dart';
// import 'package:vcard_maintained/vcard_maintained.dart';

class Profile extends StatefulWidget {
  static const id = 'profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    name = prefs.getString('name');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    showSpinner = false;
  }

  Future<void> logoutUser(context) async {
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
    await unInitializeOneSignal();
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
    await deleteTransactions();

    String msg = 'You where successfully logged out';
    String title = 'Logout';

    showPopupMessage(context, title, msg);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Scene(),
      ),
      (route) => false,
    );
  }

  String? email;
  String? name;
  String? region;
  String? phone;
  String? token;
  String avatar = '';
  bool isSubscribed = false;

  // Future<void> addContacts(List<VCard> vCards) async {
  //   for (VCard vCard in vCards) {
  //     // Extract information from vCard and create a Contact object
  //     Contact newContact = Contact(
  //       givenName: vCard.firstName,
  //       familyName: vCard.lastName,
  //       phones: _getPhones(vCard),
  //       emails: _getEmails(vCard),
  //       // Add other properties as needed
  //     );

  //     // ContactsService.getContacts();

  //     // Use addContact to add the new contact
  //     await ContactsService.addContact(newContact);
  //   }
  // }

  // List<Item> _getPhones(VCard vCard) {
  //   return [
  //     if (vCard.cellPhone != null)
  //       Item(label: 'mobile', value: vCard.cellPhone),
  //     if (vCard.pagerPhone != null)
  //       Item(label: 'pager', value: vCard.pagerPhone),
  //     if (vCard.homePhone != null) Item(label: 'home', value: vCard.homePhone),
  //     if (vCard.workPhone != null) Item(label: 'work', value: vCard.workPhone),
  //     if (vCard.otherPhone != null)
  //       Item(label: 'other', value: vCard.otherPhone),
  //   ];
  // }

  // List<Item> _getEmails(VCard vCard) {
  //   return [
  //     if (vCard.email != null) Item(label: 'email', value: vCard.email),
  //     if (vCard.workEmail != null) Item(label: 'work', value: vCard.workEmail),
  //     if (vCard.otherEmail != null)
  //       Item(label: 'other', value: vCard.otherEmail),
  //   ];
  // }

  // Future<List<VCard>> parseVCF(String filePath) async {
  //   String vcfData = await File(filePath).readAsString();
  //   return VCard.fromMap(vcfData);
  // }

  Future<void> parseVCF(String filePath) async {
    String vcfData = await File(filePath).readAsString();
    print(vcfData);
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

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    return SimpleScaffold(
      title: 'Profile',
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(0 * fem, 15 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
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
                isSubscribed
                    ? TextButton(
                        onPressed: () {},
                        child: const Text(
                          'abonnée',
                          style: TextStyle(fontSize: 13),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            SizedBox(
              height: 25.0,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25 * fem, 0 * fem, 25 * fem, 0 * fem),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfileButton(
                    title:
                        'Acceder a vos informations utlisateur pour les modifier',
                    onPress: () {
                      Navigator.pushNamed(context, ProfileMod.id)
                          .then((value) => refreshPage());
                    },
                    iconImage: Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 20 * fem, 0 * fem),
                      width: 50 * fem,
                      height: 50 * fem,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25 * fem),
                        border: Border.all(color: Color(0xfff49101)),
                        color: Color(0xffc4c4c4),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: profileImage(avatar),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  ProfileButton(
                    title: 'Acceder a vos informations d’affiliation',
                    onPress: () {
                      Navigator.pushNamed(context, Affiliation.id);
                    },
                    iconImage: Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 24.17 * fem, 0 * fem),
                      width: 41.67 * fem,
                      height: 41.67 * fem,
                      child: Image.asset(
                        'assets/design/images/subscriptions.png',
                        width: 41.67 * fem,
                        height: 41.67 * fem,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  ProfileButton(
                    title: 'Acceder aux informations de fichier de contact',
                    onPress: () {
                      // Navigator.pushNamed(context, FicheContact.id);
                      if (isSubscribed) {
                        launchURL(downloadContacts);
                        // parseVCF('assets/slides/test.vcf');
                      } else {
                        String msg = 'Vous n\'etes pas abonner';
                        String title = 'Erreur';
                        showPopupMessage(context, title, msg);
                      }
                    },
                    iconImage: Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 26.25 * fem, 0 * fem),
                      width: 37.5 * fem,
                      height: 41.67 * fem,
                      child: Image.asset(
                        'assets/design/images/permcontactcalendar.png',
                        width: 37.5 * fem,
                        height: 41.67 * fem,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  ProfileButton(
                    title: 'Rejoindre la communauter SBC sur WhatsApp',
                    onPress: () {
                      launchURL(
                          'https://chat.whatsapp.com/HRDMAQ60yMC1cHIT5Zu3o2');
                    },
                    iconImage: Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 24.27 * fem, 0 * fem),
                      width: 41.46 * fem,
                      height: 41.67 * fem,
                      child: Image.asset(
                        'assets/design/images/whatsapp.png',
                        width: 41.46 * fem,
                        height: 41.67 * fem,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 65.0 * fem,
                  ),
                  ReusableButton(
                    title: 'Deconnexion',
                    onPress: () async {
                      try {
                        setState(() {
                          showSpinner = true;
                        });

                        await logoutUser(context);

                        setState(() {
                          showSpinner = false;
                        });

                        String msg = 'You where successfully logged out';
                        String title = 'Logout';
                        showPopupMessage(context, title, msg);
                      } catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        String msg = 'An Error has occured please try again';
                        String title = 'Error';
                        showPopupMessage(context, title, msg);
                        print(e);
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 40,),
            Container(
              margin: EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 0 * fem),
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
                  'Developer par Simbtech\n copyright ©',
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
        ),
      ),
    );
  }

  void popUntilAndPush(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);

    // Now, push the new page as the first page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Scene()),
    );
  }
}
