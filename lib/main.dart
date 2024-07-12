import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/design/accueil.dart';
import 'package:snipper_frontend/design/add-product.dart';
import 'package:snipper_frontend/design/affiliation-page.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/email-oublier.dart';
import 'package:snipper_frontend/design/fiche-contact.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/modify-email.dart';
import 'package:snipper_frontend/design/notifications.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/design/profile-info.dart';
import 'package:snipper_frontend/design/profile-modify.dart';
import 'package:snipper_frontend/design/retrait.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/design/your-products.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/design/splash1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return runApp(
    MyApp(
      token: prefs.getString('token'),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.token,
    Key? key,
  }) : super(key: key);
  final String? token;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  String? get token => widget.token;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: Scene(),
      routes: {
        // '/': (context) => (token != null && JwtDecoder.isExpired(token) == false )?Accueil():Scene(),
        '/': (context) => (token != null && token!.isNotEmpty && token != '')
            ? Accueil()
            : Scene(),
        // '/': (context) => Scene(),
        Connexion.id: (context) => Connexion(),
        Inscription.id: (context) => Inscription(),
        Accueil.id: (context) => Accueil(),
        Wallet.id: (context) => Wallet(),
        Retrait.id: (context) => Retrait(),
        Notifications.id: (context) => Notifications(),
        Profile.id: (context) => Profile(),
        ProfileMod.id: (context) => ProfileMod(),
        Affiliation.id: (context) => Affiliation(),
        FicheContact.id: (context) => FicheContact(),
        Subscrition.id: (context) => Subscrition(),
        PpUpload.id: (context) => PpUpload(),
        EmailOublie.id: (context) => EmailOublie(),
        ModifyEmail.id:(context) => ModifyEmail(),
        AjouterProduit.id:(context) => AjouterProduit(),
        YourProducts.id:(context) => YourProducts(),
      },
      title: 'Sniper Business Center',
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        primaryColor: Color(0xFF92B127),
        // primarySwatch: Colors.lightGreen,
        // primaryColor: Colors.lightBlue,
      ),
    );
  }
}
