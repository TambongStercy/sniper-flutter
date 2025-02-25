import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/accueil-divertissement.dart';
import 'package:snipper_frontend/design/accueil-home.dart';
import 'package:snipper_frontend/design/accueil-investissement.dart';
import 'package:snipper_frontend/design/accueil-market.dart';
import 'package:snipper_frontend/design/accueil-publier.dart';
import 'package:snipper_frontend/design/add-product.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/design/produit-page.dart';
import 'package:snipper_frontend/design/profile-info.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/your-products.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension

class Accueil extends StatefulWidget {
  // static const id = 'accueil';

  final String? prdtId;
  final String? sellerId;

  const Accueil({Key? key, this.prdtId, this.sellerId}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 2;
  late List<Widget> _pages;
  int _homeVersion = 0;

  String avatar = '';
  String token = '';
  String id = '';
  String email = '';
  String name = '';
  bool isSubscribed = false;
  bool isPartner = false;
  bool showSpinner = true;

  String countryCode = '237';
  String momo = '';

  late SharedPreferences prefs;
  TextEditingController phoneNumberController = TextEditingController();

  get sellerId => widget.sellerId;
  get prdtId => widget.prdtId;

  @override
  void initState() {
    super.initState();

    _selectedIndex = (prdtId != null && sellerId != null) ? 3 : 2;

    _pages = <Widget>[
      const Publicite(),
      const Divertissement(),
      Home(changePage: onItemTapped),
      Market(),
      const Investissement(),
    ];

    () async {
      try {
        await getInfos();

        if (prdtId != null && sellerId != '') {
          final prdtAndUser = await getProductOnline(sellerId, prdtId);

          context.pushNamed(
            ProduitPage.id,
            extra: prdtAndUser, // Pass the prdtAndUser object directly
          );
        }

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
        Home(
          changePage: onItemTapped,
          key: ValueKey<int>(_homeVersion),
        ),
        Market(),
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
        final balance = user['balance'].floorToDouble();
        final benefit = user['benefits'].floorToDouble();

        final partner = user['partner'];

        final whatsappLink = links['whatsapp'];
        final telegramLink = links['telegram'];

        name = user['name'] ?? name;
        isSubscribed = user['isSubscribed'] ?? false;

        final momo = user['momoNumber'];
        final momoCorrespondent = user['momoCorrespondent'];

        if (momo != null) {
          prefs.setString('momo', momo.toString());

          if (momoCorrespondent != null) {
            prefs.setString('momoCorrespondent', momoCorrespondent);
          }
        }

        prefs.setString('name', name);
        prefs.setString('whatsapp', whatsappLink);
        prefs.setString('telegram', telegramLink);
        prefs.setString('region', region);
        prefs.setString('phone', phone);
        prefs.setString('code', userCode);
        prefs.setDouble('balance', balance);
        prefs.setDouble('benefit', benefit);

        if (!isSubscribed) {
          context.goNamed(Subscrition.id);
        }

        if (partner != null) {
          final partnerAmount = partner['amount'].toDouble();
          final partnerPack = partner['pack'];
          prefs.setDouble('partnerAmount', partnerAmount);
          prefs.setString('partnerPack', partnerPack);
          isPartner = true;
        }

        prefs.setBool('isSubscribed', isSubscribed);
        notifCount = 0;

        if (!isSubscribed) {
          print('add Notification');
        }
        if (momo == null) {
          // _showPhoneNumberDialog();
        }

        _homeVersion++;
        refreshPage();
      } else {
        if (error == 'Accès refusé') {
          String title = context.translate('error_access_denied');
          showPopupMessage(context, title, msg);

          if (!kIsWeb) {
            await deleteFile(avatar);
          }

          prefs.clear();
          await deleteNotifications();
          await deleteAllKindTransactions();

          context.go('/');
        }

        String title = context.translate('error');
        showPopupMessage(context, title, msg);
      }
    } catch (e) {
      print(e);
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    }
  }

  Future<dynamic> getProductOnline(String sellerId, String prdtId) async {
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url =
          Uri.parse('$getProduct?seller=$sellerId&id=$prdtId&email=$email');

      print(url);

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      print(jsonResponse);

      if (response.statusCode == 200) {
        final userAndPrdt = jsonResponse['userPrdt'];

        if (mounted) setState(() {});

        return userAndPrdt;
      } else {
        if (error == 'Accès refusé') {
          String title = context.translate('error_access_denied');
          showPopupMessage(context, title, msg);
        }

        String title = context.translate('error');
        showPopupMessage(context, title, msg);

        print('something went wrong');
      }
    } catch (e) {
      print(e);
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    }
  }

  int notifCount = 0;
  int selected = 0;

  void _showPhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            context.translate('enter_mobile_money'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: CustomTextField(
            margin: 5,
            hintText: context.translate('mobile_number_example'),
            value: momo,
            onChange: (val) {
              momo = val;
            },
            getCountryDialCode: (code) {
              countryCode = code;
            },
            type: 5,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(context.translate('ok')),
              onPressed: () async {
                await addMOMO();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addMOMO() async {
    String msg = '';
    String error = '';
    setState(() {
      showSpinner = true;
    });
    try {
      final sendPone = countryCode + momo;

      final regBody = {
        'id': id,
        'email': email,
        'momo': sendPone,
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(modMomo),
        headers: headers,
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      final title = (response.statusCode == 200)
          ? context.translate('success')
          : context.translate('error');

      prefs.setString('momo', sendPone);
      if (email != '') prefs.setString('email', email);

      context.pop();
      showPopupMessage(context, title, msg);
      print(msg);
    } catch (e) {
      print(e);
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    }
    setState(() {
      showSpinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;

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
              onPressed: () {},
            ),
          IconButton(
            icon: Icon(Icons.wallet),
            color: Colors.black,
            iconSize: 24,
            onPressed: () {
              context.pushNamed(Wallet.id).then((value) {
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
                border:
                    Border.all(color: isPartner ? orange : blue, width: 2.0),
              ),
              child: Container(
                width: 35 * fem,
                height: 35 * fem,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25 * fem),
                  border: Border.all(color: Colors.white),
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
              context.pushNamed(Profile.id).then((value) {
                if (mounted) {
                  setState(() {
                    initSharedPref();
                  });
                }
              });
            },
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 3 && isSubscribed
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme:
                  const IconThemeData(size: 22.0, color: Colors.white),
              overlayColor: Colors.black,
              overlayOpacity: 0.4,
              backgroundColor: blue,
              children: [
                SpeedDialChild(
                  onTap: () {
                    context.pushNamed(AjouterProduit.id);
                  },
                  child: Icon(Icons.add, color: Colors.black, size: 30),
                ),
                SpeedDialChild(
                  onTap: () {
                    context.pushNamed(YourProducts.id);
                  },
                  child: Icon(Icons.edit, color: Colors.black, size: 30),
                ),
              ],
            )
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
              text: context.translate('advertising'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Colors.white),
            ),
            GButton(
              icon: Icons.hail_rounded,
              text: context.translate('entertainment'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Colors.white),
            ),
            GButton(
              icon: Icons.home,
              text: context.translate('home'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Colors.white),
            ),
            GButton(
              icon: Icons.shopping_cart,
              text: context.translate('marketplace'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Colors.white),
            ),
            GButton(
              icon: Icons.monetization_on,
              text: context.translate('investment'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
