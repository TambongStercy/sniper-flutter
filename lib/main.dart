import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/design/accueil-market.dart';
import 'package:snipper_frontend/design/accueil.dart';
import 'package:snipper_frontend/design/add-product.dart';
import 'package:snipper_frontend/design/affiliation-page.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/email-oublier.dart';
import 'package:snipper_frontend/design/espace-partenaire.dart';
import 'package:snipper_frontend/design/fiche-contact.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/modify-email.dart';
import 'package:snipper_frontend/design/notifications.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/design/produit-page.dart';
import 'package:snipper_frontend/design/profile-info.dart';
import 'package:snipper_frontend/design/profile-modify.dart';
import 'package:snipper_frontend/design/retrait.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/design/your-products.dart';
import 'package:snipper_frontend/design/splash1.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatefulWidget {
  final String? token;

  const MyApp({Key? key, required this.token}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    _initUniLinks();
    super.initState();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Deep linking handling
  Future<void> _initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      _linkSubscription = linkStream.listen((String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _handleDeepLink(String link) {
    Uri uri = Uri.parse(link);
    // Check if the link has an affiliationCode and navigate accordingly
    if (uri.path.contains('inscription')) {
      String? affiliationCode = uri.queryParameters['affiliationCode'];
      Navigator.pushNamed(
        context,
        Inscription.id,
        arguments: affiliationCode,
      );
    } else if (uri.path.contains('affiliation')) {
      Navigator.pushNamed(context, Affiliation.id);
    } else if (uri.path.contains('add-product')) {
      Navigator.pushNamed(context, AjouterProduit.id);
    } else if (uri.path.contains('notifications')) {
      Navigator.pushNamed(context, Notifications.id);
    }
    // Add other link handling cases as needed
  }

  String? get token => widget.token;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => (token != null && token!.isNotEmpty && token != '')
            ? Accueil()
            : Scene(),
        EspacePartenaire.id: (context) => EspacePartenaire(),
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
        ModifyEmail.id: (context) => ModifyEmail(),
        AjouterProduit.id: (context) => AjouterProduit(),
        YourProducts.id: (context) => YourProducts(),
      },
      onGenerateRoute: (settings)  {
        if (settings.name == Inscription.id) {
          final String? affiliationCode = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => Inscription(affiliationCode: affiliationCode),
          );
        }
        if (settings.name == ProduitPage.id) {
          // final ScreenArguments? args = settings.arguments as ScreenArguments?;

          // if (args != null) {
          //   getProductOnline(args.sellerEmail, args.prdtId, context).then((userPrdt) {
          //     return MaterialPageRoute(builder: (context) => ProduitPage(prdtAndUser: userPrdt,));
          //   });
          // }
        }

        // Define other onGenerateRoutes if necessary
        return null;
      },
      title: 'Snipper Business Center',
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        primaryColor: Color(0xFF92B127),
      ),
    );
  }
}
