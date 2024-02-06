import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/accueil-divertissement.dart';
import 'package:snipper_frontend/design/accueil-home.dart';
import 'package:snipper_frontend/design/accueil-investissement.dart';
import 'package:snipper_frontend/design/accueil-market.dart';
import 'package:snipper_frontend/design/accueil-publier.dart';
import 'package:snipper_frontend/design/notifications.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/design/profile-info.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/utils.dart';

class Accueil extends StatefulWidget {
  static const id = 'accueil';

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  String token = '';
  String id = '';
  String email = '';
  String name = '';
  bool isSubscribed = false;
  bool showSpinner = true;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    _pages = <Widget>[
      Home(changePage: onItemTapped),
      const Publicite(),
      const Market(),
      const Divertissement(),
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
        Home(changePage: onItemTapped),
        const Publicite(),
        const Market(),
        const Divertissement(),
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
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void>? getInfos() async {
    await initSharedPref();
    await initializeOneSignal(id);

    print(token);
    print(email);
    print(name);
    print(isSubscribed);

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final url = Uri.parse('$getUpdates?email=$email');

    final response = await http.get(url, headers: headers);

    final jsonResponse = jsonDecode(response.body);

    // final myToken = jsonResponse['token'];

    final user = jsonResponse['user'];

    final region = user['region'];
    final phone = user['phoneNumber'].toString();
    final userCode = user['code'];
    final balance = user['balance'];
    name = user['name'] ?? name;
    isSubscribed = user['isSubscribed'] ?? false;

    if (response.statusCode == 200) {
      print(phone);
      prefs.setString('name', name);
      prefs.setString('region', region);
      prefs.setString('phone', phone);
      prefs.setString('code', userCode);
      prefs.setInt('balance', balance);
      prefs.setBool('isSubscribed', isSubscribed);
      notifCount = 0;
      print('isSubscribed = $isSubscribed');
      if (!isSubscribed) {
        print('add Notification');
        addCallbackOnNotif(duringNotification);
      }

      print('all good');
    } else {
      // Handle errors,
      print('something went wrong');
    }
  }

  int notifCount = 0;

  Future<void> duringNotification(OSNotificationWillDisplayEvent event) async {
    print('refreshing for subscription');

    final notification = event.notification;

    String notificationTitle = notification.title ?? "No Title";
    String newNotifId = notification.rawPayload?['google.message_id'];

    if (newNotifId == notifId) {
      return print('inside accueil break');
    }

    notifId = newNotifId;

    if (notificationTitle == 'Sniper abonnement') {
      try {
        showSpinner = true;
        refreshPage();
        await getInfos();
        showSpinner = false;
        refreshPage();
      } catch (e) {
        print(e);
        showSpinner = false;
        refreshPage();
      }
    }
  }

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff92b127),
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
          IconButton(
            icon: Icon(Icons.wallet),
            color: Colors.white,
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
            icon: const Icon(Icons.person),
            color: Colors.white,
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
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, Notifications.id).then((value) {
                if (mounted) {
                  setState(() {
                    initSharedPref();
                  });
                }
              });
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Expanded(
          child: SingleChildScrollView(
            child: _pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: limeGreen,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: GNav(
          selectedIndex: _selectedIndex,
          onTabChange: onItemTapped,
          backgroundColor: limeGreen,
          color: Colors.white,
          activeColor: Colors.white,
          tabActiveBorder: Border.all(color: Colors.white),
          padding: const EdgeInsets.all(10.0),
          gap: 5,
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Accueil',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Color(0xff25313c),
              ),
            ),
            GButton(
              icon: Icons.public,
              text: 'Publicité',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Color(0xff25313c),
              ),
            ),
            GButton(
              icon: Icons.store,
              text: 'Market place',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Color(0xff25313c),
              ),
            ),
            GButton(
              icon: (Icons.hail_sharp),
              text: 'Divertissement',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Color(0xff25313c),
              ),
            ),
            GButton(
              icon: Icons.monetization_on,
              text: 'Investissement',
              textStyle: SafeGoogleFont(
                'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1 * fem,
                color: Color(0xff25313c),
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
