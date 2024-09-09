import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/accueil-divertissement.dart';
import 'package:snipper_frontend/design/accueil-home.dart';
import 'package:snipper_frontend/design/accueil-investissement.dart';
import 'package:snipper_frontend/design/accueil-market.dart';
import 'package:snipper_frontend/design/accueil-publier.dart';
import 'package:snipper_frontend/design/add-product.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/design/profile-info.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/design/splash1.dart';
import 'package:snipper_frontend/design/your-products.dart';
import 'package:snipper_frontend/utils.dart';

class Accueil extends StatefulWidget {
  static const id = 'accueil';

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 2;
  late List<Widget> _pages;

  String avatar = '';
  String token = '';
  String id = '';
  String email = '';
  String name = '';
  bool isSubscribed = false;
  bool isPartner = false;
  bool showSpinner = true;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    _pages = <Widget>[
      const Publicite(),
      const Divertissement(),
      Home(changePage: onItemTapped),
      const Market(),
      const Investissement(),
    ];

    // Create anonymous function:
    () async {
      try {
        await getInfos();
        showSpinner = false;
        refreshPage();
      } catch (e) {
        print(e);
        showSpinner = false;
        refreshPage();
      }
    }();
  }

  refreshPage() {
    if (mounted) {
      _pages = <Widget>[
        const Publicite(),
        const Divertissement(),
        Home(changePage: onItemTapped),
        const Market(),
        const Investissement(),
      ];
      setState(() {
        // Update your UI with the desired changes.
      });
    }
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    id = prefs.getString('id') ?? '';
    token = prefs.getString('token') ?? '';
    email = prefs.getString('email') ?? '';
    name = prefs.getString('name') ?? '';
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void>? getInfos() async {
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$getUpdates?email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        final user = jsonResponse['user'];
        final links = jsonResponse['links'];

        final region = user['region'];
        final phone = user['phoneNumber'].toString();
        final userCode = user['code'];
        final balance = user['balance'].toDouble();

        final partner = user['partner'];

        final whatsappLink = links['whatsapp'];
        final telegramLink = links['telegram'];

        name = user['name'] ?? name;
        isSubscribed = user['isSubscribed'] ?? false;

        prefs.setString('name', name);
        prefs.setString('whatsapp', whatsappLink);
        prefs.setString('telegram', telegramLink);
        prefs.setString('region', region);
        prefs.setString('phone', phone);
        prefs.setString('code', userCode);
        prefs.setDouble('balance', balance);

        if (partner != null) {
          final partnerAmount = partner['amount'].toDouble();
          final partnerPack = partner['pack'];
          final partnerTrans = partner['transactions'];
          prefs.setDouble('partnerAmount', partnerAmount);
          prefs.setString('partnerPack', partnerPack);
          prefs.setDouble('partnerTrans', partnerTrans);
          isPartner = true;
        }

        prefs.setBool('isSubscribed', isSubscribed);
        notifCount = 0;

        if (!isSubscribed) {
          print('add Notification');
        }
      } else {
        if (error == 'Accès refusé') {
          String title = "Erreur. Accès refusé.";
          showPopupMessage(context, title, msg);

          if (!kIsWeb) {
            await deleteFile(avatar);
            // await unInitializeOneSignal();
          }

          prefs.setString('token', '');
          prefs.setString('id', '');
          prefs.setString('email', '');
          prefs.setString('name', '');
          prefs.setString('token', '');
          prefs.setString('region', '');
          prefs.setString('phone', '');
          prefs.setString('code', '');
          prefs.setString('avatar', '');
          prefs.setDouble('balance', 0);
          prefs.setBool('isSubscribed', false);
          await deleteNotifications();
          await deleteAllKindTransactions();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Scene(),
            ),
            (route) => false,
          );

          // String logoutMsg = 'You where successfully logged out';
          // String logoutTitle = 'Logout';

          // showPopupMessage(context, logoutTitle, logoutMsg);
        }

        String title = 'Erreur';
        showPopupMessage(context, title, msg);

        // Handle errors,
        print('something went wrong');
      }
    } catch (e) {
      print(e);
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  int notifCount = 0;

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffffff),
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: 83 * fem,
          height: 33 * fem,
          child: Image.asset(
            'assets/design/images/logo-sbc-final-1-tnu.png',
            fit: BoxFit.cover,
          ),
        ),
        actions: [
          if (kIsWeb)
            IconButton(
              icon: Icon(Icons.download_rounded),
              color: Colors.black,
              onPressed: () {
                // Navigator.pushNamed(context, Notifications.id).then((value) {
                //   if (mounted) {
                //     setState(() {
                //       initSharedPref();
                //     });
                //   }
                // });
              },
            ),
          IconButton(
            icon: Icon(Icons.wallet),
            color: Colors.black,
            iconSize: 24,
            onPressed: () {
              Navigator.pushNamed(context, Wallet.id).then((value) {
                if (mounted) {
                  setState(() {
                    initSharedPref();
                  });
                }
              });
            },
          ),
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25 * fem),
                border: Border.all(color: isPartner?orange:blue, width: 2.0),
              ),
              child: Container(
                width: 35 * fem,
                height: 35 * fem,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25 * fem),
                  border: Border.all(color: Colors.white),
                  // border: Border.all(color: Color(0xfff49101)),
                  color: Color(0xffc4c4c4),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: profileImage(avatar),
                  ),
                ),
              ),
            ),
            color: Colors.black,
            iconSize: 24,
            onPressed: () {
              Navigator.pushNamed(context, Profile.id).then((value) {
                if (mounted) {
                  setState(() {
                    initSharedPref();
                  });
                }
              });
            },
          ),
          SizedBox(
            width: 20.0,
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 3 && isSubscribed
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: const IconThemeData(
                size: 22.0,
                color: Colors.white,
              ),
              overlayColor: Colors.black,
              overlayOpacity: 0.4,
              backgroundColor: blue,
              children: [
                SpeedDialChild(
                  onTap: () {
                    Navigator.pushNamed(context, AjouterProduit.id);
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 30,
                  ),
                  // label: 'Ajouter un produit',
                ),
                SpeedDialChild(
                  onTap: () {
                    Navigator.pushNamed(context, YourProducts.id);
                  },
                  child: Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 30,
                  ),
                  // label: 'Modifier vos produits',
                ),
              ],
            )

          // FloatingActionButton(
          //     backgroundColor: limeGreen,
          //     onPressed: () {
          //       Navigator.pushNamed(context, AjouterProduit.id);
          //     },
          // child: Icon(
          //   Icons.add,
          //   color: Colors.white,
          //   size: 30,
          // ),
          //   )
          : null,
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: GNav(
          selectedIndex: _selectedIndex,
          onTabChange: onItemTapped,
          backgroundColor: Colors.white,
          color: Colors.black87,
          activeColor: Colors.white,
          tabBackgroundColor: orange,
          padding: const EdgeInsets.all(10.0),
          gap: 5,
          tabs: [
            GButton(
              icon: Icons.remove_red_eye_sharp,
              text: 'Publicité',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Colors.white,
              ),
            ),
            GButton(
              icon: (Icons.hail_rounded),
              text: 'Divertissement',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Colors.white,
              ),
            ),
            GButton(
              icon: Icons.home,
              text: 'Accueil',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Colors.white,
              ),
            ),
            GButton(
              icon: Icons.shopping_cart,
              text: 'Market place',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Colors.white,
              ),
            ),
            GButton(
              icon: Icons.monetization_on,
              text: 'Investissement',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNavigationDestination extends StatelessWidget {
  final IconData icon;
  final String label;
  final double fontSize;

  CustomNavigationDestination(
      {required this.icon, required this.label, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        Text(
          label,
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }
}
