import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/adverscard.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/moneycard.dart';
import 'package:snipper_frontend/components/videoitem.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/theme.dart';

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
                  style: SafeGoogleFont(
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
    code = prefs.getString('code');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
    balance = prefs.getDouble('balance') ?? 0;
    benefice = prefs.getDouble('benefit') ?? 0;

    // Construct the URI
    Uri uri = Uri.parse('${frontEnd}inscription')
        .replace(queryParameters: {'affiliationCode': code});

    link = uri.toString();

    // Load dynamic file IDs from SharedPreferences
    presentationPdfId = prefs.getString('appSettings_presentationPdfId');
    presentationVideoId = prefs.getString('appSettings_presentationVideoId');
  }

  void Function(int) get changePage => widget.changePage;

  String? email;
  String name = '';
  String? code;
  String link = '';
  String? region;
  String? phone;
  String? token;
  double balance = 0;
  double benefice = 0;
  String avatar = '';
  bool isSubscribed = false;

  // Add state variables for dynamic file IDs
  String? presentationPdfId;
  String? presentationVideoId;
  // String? videoThumbnailId; // Remove - Thumbnail uses video ID

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
    // Load ID from state
    if (presentationPdfId != null && presentationPdfId!.isNotEmpty) {
      final url = '$settingsFileBaseUrl$presentationPdfId';
      print("Launching Presentation URL: $url");
      launchURL(url);
    } else {
      print("Presentation PDF ID not found.");
      showPopupMessage(context, context.translate('error'),
          context.translate('file_not_available')); // Add translation
    }
    // launchURL('$downloadPres?language=fr'); // Remove old static URL
  }

  @override
  void initState() {
    super.initState();

    unsubSlides.shuffle();

    // Call initSharedPref here
    _initializeHomeData();
  }

  // Helper for async initState
  Future<void> _initializeHomeData() async {
    await initSharedPref();
    if (mounted) {
      setState(() {
        // Update your UI with the desired changes.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    final slides = isSubscribed ? subSlides : unsubSlides;

    return RefreshIndicator(
      onRefresh: () async {
        await initSharedPref();
        if (mounted) {
          setState(() {});
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * fem, 24 * fem, 16 * fem, 24 * fem),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome section
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.only(bottom: 20 * fem),
                child: Padding(
                  padding: EdgeInsets.all(20 * fem),
                  child: Column(
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
                              style: TextStyle(
                                fontSize: 24 * ffem,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            ',',
                            style: TextStyle(
                              fontSize: 24 * ffem,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * fem),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: context.translate('welcome_sniper'),
                            ),
                            TextSpan(
                              text: 'SBC',
                              style: TextStyle(
                                fontSize: 18 * ffem,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            TextSpan(
                              text: context.translate('welcome_message'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Balance and Benefits Cards
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.only(bottom: 20 * fem),
                child: Padding(
                  padding: EdgeInsets.all(16 * fem),
                  child: Column(
                    children: [
                      MoneyCard(isSold: true, amount: balance),
                      SizedBox(height: 12 * fem),
                      MoneyCard(isSold: false, amount: benefice),
                    ],
                  ),
                ),
              ),

              // Referral Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.only(bottom: 20 * fem),
                child: Padding(
                  padding: EdgeInsets.all(20 * fem),
                  child: Column(
                    children: [
                      Image.asset('assets/assets/images/50 perc.png'),
                      SizedBox(height: 20 * fem),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Share.share(link);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16 * fem),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            context.translate('share_link'),
                            style: TextStyle(
                              fontSize: 16 * ffem,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // About SBC
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.only(bottom: 20 * fem),
                child: Padding(
                  padding: EdgeInsets.all(20 * fem),
                  child: Column(
                    children: [
                      Text(
                        context.translate('about_sbc'),
                        style: TextStyle(
                          fontSize: 20 * ffem,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12 * fem),
                      Text(
                        context.translate('sbc_description'),
                        style: TextStyle(
                          fontSize: 14 * ffem,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Market Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.only(bottom: 20 * fem),
                child: Padding(
                  padding: EdgeInsets.all(16 * fem),
                  child: MarketCard(),
                ),
              ),

              // Carousel Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.only(bottom: 20 * fem),
                child: Padding(
                  padding: EdgeInsets.all(16 * fem),
                  child: AdCard(
                    height: 300,
                    buttonTitle: context.translate('learn_more'),
                    buttonAction: () {
                      changePage(1);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5 * fem),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12 * fem),
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
                ),
              ),

              // Video Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.only(bottom: 20 * fem),
                child: Padding(
                  padding: EdgeInsets.all(16 * fem),
                  child: AdCard(
                    height: 300,
                    buttonTitle: context.translate('download_document'),
                    buttonAction: downloadPresentation,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                          horizontal: 15 * fem, vertical: 5 * fem),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 * fem),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 200 * fem,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12 * fem),
                        ),
                        child: (presentationVideoId != null &&
                                presentationVideoId!.isNotEmpty)
                            ? Builder(builder: (context) {
                                final videoUrl =
                                    '$settingsFileBaseUrl$presentationVideoId';
                                final thumbnailUrl =
                                    '$settingsThumbnailBaseUrl$presentationVideoId';

                                return VideoItem(
                                  videoUrl: videoUrl,
                                  thumbnailUrl: thumbnailUrl,
                                );
                              })
                            : Container(
                                child: Center(
                                    child: Text(context
                                        .translate('video_unavailable'))),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              // Subscription call to action
              if (!isSubscribed)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  margin: EdgeInsets.only(bottom: 20 * fem),
                  child: Padding(
                    padding: EdgeInsets.all(20 * fem),
                    child: Column(
                      children: [
                        Text(
                          context.translate('join_community'),
                          style: TextStyle(
                            fontSize: 18 * ffem,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 12 * fem),
                        Container(
                          padding: EdgeInsets.all(12 * fem),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8 * fem),
                            color: Colors.grey[100],
                          ),
                          child: Text(
                            context.translate('subscription_not_active'),
                            style: TextStyle(
                              fontSize: 14 * ffem,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * fem),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushNamed(Subscrition.id);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16 * fem),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              context.translate('pay_subscription'),
                              style: TextStyle(
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * fem),
                        Container(
                          padding: EdgeInsets.all(12 * fem),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8 * fem),
                            color: Colors.grey[100],
                          ),
                          child: Text(
                            context.translate('invite_friends_message'),
                            style: TextStyle(
                              fontSize: 14 * ffem,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
