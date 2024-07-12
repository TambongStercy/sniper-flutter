import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/adverscard.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/videoitem.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/utils.dart';

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
    name = prefs.getString('name');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  void Function(int) get changePage => widget.changePage;

  String? email;
  String? name = '';
  String? region;
  String? phone;
  String? token;
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
        margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
        padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(7 * fem, 0 * fem, 0 * fem, 20 * fem),
              constraints: BoxConstraints(
                maxWidth: 325 * fem,
              ),
              child: RichText(
                text: TextSpan(
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 15 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1.4 * ffem / fem,
                    color: Color(0xff25313c),
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Bienvenue ',
                    ),
                    TextSpan(
                      text: name?.toUpperCase(),
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 15 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1.4 * ffem / fem,
                        color: limeGreen,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' à la sniper Business Center, la communauté la plus dynamique du Cameroun.',
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(7 * fem, 0 * fem, 0 * fem, 5 * fem),
              child: Text(
                'A l’affiche',
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 16 * ffem,
                  fontWeight: FontWeight.w600,
                  height: 1.25 * ffem / fem,
                  color: Color(0xfff49101),
                ),
              ),
            ),
            AdCard(
              height: 300,
              buttonTitle: 'En savoir plus',
              buttonAction: () {
                //Go to marketPlace
                changePage(2);
              },
              child: Container(
                padding: EdgeInsets.all(5 * fem),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * fem),
                  color: Colors.black,
                ),
                child: AnotherCarousel(
                  images: slides.map((name) {
                    return AssetImage('assets/slides/$name.jpg');
                  }).toList(),
                  boxFit: BoxFit.contain,
                  showIndicator: false,
                  dotSize: 3.0,
                  borderRadius: true,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(7 * fem, 0 * fem, 0 * fem, 15 * fem),
              child: Text(
                'C’est quoi Sniper Business Center ?',
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 16 * ffem,
                  fontWeight: FontWeight.w600,
                  height: 1.25 * ffem / fem,
                  color: Color(0xfff49101),
                ),
              ),
            ),
            AdCard(
              height: 300,
              buttonTitle: 'Telecharger le document',
              buttonAction: downloadPresentation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * fem),
                  border: Border.all(color: Colors.grey, width: 1.0),
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
