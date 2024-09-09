import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/adverscard.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/moneycard.dart';
import 'package:snipper_frontend/components/videoitem.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/utils.dart';

class MarketCard extends StatelessWidget {
  MarketCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 25, left: 30, right: 30),
            decoration: BoxDecoration(
              color: Color(0xFF0066FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Découvrez notre Marché',
                  style: SafeGoogleFont(
                      'Montserrat',
                      letterSpacing: 0.0,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Vendez vos produits sans effort.\n'
                  'Connectez-vous avec des acheteurs et\n'
                  'boostez vos ventes dès aujourd\'hui!',
                  style:  SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: -30, // Exceeds the container
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF99CC33), // Green circle background
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, // White border
                  width: 4,
                ),
              ),
              child: Icon(
                Icons.shopping_cart,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class Home extends StatefulWidget {
  Home({
    super.key,
    required this.changePage,
    this.onSetState,
  });

  void Function(int) changePage;
  bool? onSetState;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    name = prefs.getString('name') ?? '';
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
    balance = prefs.getDouble('balance') ?? 0;

    benefice = await getTransactionsBenefit();
  }

  void Function(int) get changePage => widget.changePage;

  String? email;
  String name = '';
  String? region;
  String? phone;
  String? token;
  double balance = 0;
  double benefice = 0;
  String avatar = '';
  bool isSubscribed = false;

  // Create a List of Strings
  List<String> unsubSlides = [
    'IMG14',
    'IMG15',
    'IMG16',
    'IMG17',
    'IMG18',
    'IMG19',
    'IMG20',
    'IMG21',
    'IMG22',
    'IMG23',
    'IMG24',
    'IMG25',
    'IMG26',
    'IMG27',
    'IMG28',
    'IMG29',
    'IMG30',
    'IMG31',
    'IMG32',
    'IMG33',
    'IMG34',
    'IMG35',
    'IMG36',
    'IMG37',
    'IMG38',
    'IMG39',
    'IMG40',
    'IMG41',
    'IMG42',
    'IMG43',
    'IMG44',
    'IMG45',
    'IMG46',
    'IMG47',
    'IMG48',
    'IMG49',
    'IMG50',
    'IMG51',
    'IMG52',
    'IMG53',
    'IMG54',
    'IMG55',
    'IMG56',
    'IMG57',
    'IMG58',
    'IMG59',
    'IMG60',
    'IMG61',
    'IMG62',
    'IMG63',
    'IMG64',
    'IMG65',
    'IMG66',
    'IMG67',
    'IMG68',
    'IMG69',
    'IMG70',
    'IMG71',
    'IMG72',
    'IMG73',
  ];

  List<String> subSlides = [
    'slide 1 fr',
    'slide 2 fr',
    'slide 3 fr',
  ];

  void downloadPresentation() {
    launchURL('$downloadPres?language=fr');
  }

  @override
  void initState() {
    super.initState();

    unsubSlides.shuffle();

    // Create anonymous function:
    () async {
      await initSharedPref();
      if (mounted) {
        setState(() {
          // Update your UI with the desired changes.
        });
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    // widget.onSetState = false;

    final slides = isSubscribed ? subSlides : unsubSlides;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(0 * fem, 25 * fem, 0 * fem, 14 * fem),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 170 * fem,
                  ),
                  child: Text(
                    capitalizeWords(name),
                    overflow: TextOverflow.ellipsis,
                    style: SafeGoogleFont(
                      'Montserrat',
                      letterSpacing: 0.0 * fem,
                      fontSize: 25 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.4 * ffem / fem,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  ',',
                  overflow: TextOverflow.ellipsis,
                  style: SafeGoogleFont(
                    'Montserrat',
                    letterSpacing: 0.0 * fem,
                    fontSize: 22 * ffem,
                    fontWeight: FontWeight.w700,
                    height: 1.4 * ffem / fem,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(7 * fem, 0 * fem, 0 * fem, 20 * fem),
              constraints: BoxConstraints(
                maxWidth: 325 * fem,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 17 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1.4 * ffem / fem,
                    color: Color(0xff25313c),
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Sniper Business Center (',
                    ),
                    TextSpan(
                      text: 'SBC',
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 20 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1.4 * ffem / fem,
                        color: limeGreen,
                      ),
                    ),
                    const TextSpan(
                      text: ') vous souhaite la bienvenue!',
                    )
                  ],
                ),
              ),
            ),
            MoneyCard(isSold: true, amount: balance),
            MoneyCard(isSold: false, amount: benefice),
            SizedBox(height: 20.0),
            Image.asset('assets/assets/images/50 perc.png'),
            SizedBox(height: 20.0),
            ReusableButton(
              title: 'Partagez mon code',
              lite: false,
              onPress: () {},
            ),
            Text(
              'À propos de SBC',
              style: SafeGoogleFont(
                'Montserrat',
                letterSpacing: 0.0 * fem,
                fontSize: 22 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.4 * ffem / fem,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'SBC est la communauté la plus dynamique du Cameroun qui offre les services',
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 15 * ffem,
                fontWeight: FontWeight.w500,
                height: 1.4 * ffem / fem,
                color: Color(0xff25313c),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            MarketCard(),
            AdCard(
              height: 300,
              buttonTitle: 'En savoir plus',
              buttonAction: () {
                //Go to marketPlace
                changePage(1);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5 * fem),
                // width: double.infinity,
                // margin: EdgeInsets.symmetric(
                //     horizontal: 15 * fem, vertical: 5 * fem),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(12 * fem),
                  color: Colors.black26,
                ),
                child: AnotherCarousel(
                  images: slides.map((name) {
                    return AssetImage('assets/slides/$name.jpg');
                  }).toList(),
                  boxFit: BoxFit.contain,
                  showIndicator: false,
                  dotSize: 3.0,
                  borderRadius: true,
                  // animationDuration: const Duration(milliseconds: 10000),
                ),
              ),
            ),
            AdCard(
              height: 300,
              buttonTitle: 'Telecharger le document',
              buttonAction: downloadPresentation,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                    horizontal: 15 * fem, vertical: 5 * fem),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * fem),
                ),
                child: const VideoItem(),
              ),
            ),
            !isSubscribed
                ? Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            7 * fem, 0 * fem, 0 * fem, 9 * fem),
                        child: Text(
                          'Rejoindre la communauté',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.25 * ffem / fem,
                            color: Color(0xfff49101),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(7 * fem),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5 * fem),
                          color: Color.fromARGB(255, 244, 245, 248),
                        ),
                        child: Text(
                          'Votre abonnement n’est pas encore activé. Pour profiter pleinement des avantages du réseau sniper business center , veuillez procéder au paiement de votre inscription.',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 15 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.4 * ffem / fem,
                            color: Color.fromARGB(255, 91, 92, 96),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ReusableButton(
                        title: 'Payer mon inscription',
                        onPress: () {
                          Navigator.pushNamed(context, Subscrition.id);
                        },
                        lite: false,
                      ),
                      Container(
                        padding: EdgeInsets.all(7 * fem),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5 * fem),
                          color: Color.fromARGB(255, 244, 245, 248),
                        ),
                        child: Text(
                          'Cependant, vous avez la possibilité de commencer à inviter d’autres personnes à rejoindre le réseau et payer votre inscription avec les commissions que vous recevez . Génial n’est ce pas ?',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 15 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.4 * ffem / fem,
                            color: Color.fromARGB(255, 91, 92, 96),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
