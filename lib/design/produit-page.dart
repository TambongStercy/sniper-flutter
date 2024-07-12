import 'dart:convert';

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/filleulscard.dart';
// import 'package:snipper_frontend/components/prodtpost.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;

class ProduitPage extends StatefulWidget {
  static const id = 'productpage';

  const ProduitPage({super.key, required this.prdtAndUser});

  final prdtAndUser;

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  String email = '';
  String token = '';
  bool isSubscribed = false;

  get prdtAndUser => widget.prdtAndUser;

  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    token = prefs.getString('token') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  @override
  void initState() {
    super.initState();
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

  Future<void> rateProduct(
    String sellerId,
    String prdtId,
    double rating,
  ) async {
    // email, sellerId, prdtId, rating
    String msg = '';
    String error = '';
    try {
      final regBody = {
        'sellerId': sellerId,
        'email': email,
        'prdtId': prdtId,
        'rating': rating,
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(rateThisProduct),
        headers: headers,
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      final title = (response.statusCode == 200) ? 'Success' : 'Error';

      showPopupMessage(context, title, msg);
      print(msg);
    } catch (e) {
      print(e);
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  void showRatingBar(
    BuildContext context,
    prdtAndUser,
  ) {
    final prdt = prdtAndUser['product'];
    final prdtId = prdt['id'];

    final seller = prdtAndUser['userInfo'];
    final sellerId = seller['id'];

    double userRating = 3;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Votre avis sur le produit?',
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: Color(0xff25313c),
            ),
          ),
          content: RatingBar.builder(
            initialRating: userRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                userRating = rating;
              });
              print(rating);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await rateProduct(sellerId, prdtId, userRating);
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prdt = prdtAndUser['product'];
    final link = prdt['whatsappLink'];
    final prdtName = prdt['name'];
    // final category = prdt['category'];
    final description = prdt['description'];
    final imagesUrl = prdt['urls'];
    final rating = (prdt['overallRating'] ?? 0.0).toDouble();
    final price = prdt['price'] ?? 0;

    final seller = prdtAndUser['userInfo'];
    final sellerName = seller['name'];
    final sellerUrl = seller['url'];
    final sellerEmail = seller['email'];
    final sellerRegion = seller['region'];
    final sellerPhone = seller['phoneNumber'].toString();

    final country = getCountryFromPhoneNumber(sellerPhone)!;

    // final imageWidget = NetworkImage(imagesUrl[0]);

    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40 * fem,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                        ),
                        PopupMenuButton(
                          onSelected: (value) {
                            if (value == '/rate') {
                              showRatingBar(context, prdtAndUser);
                            }
                          },
                          itemBuilder: (BuildContext bc) {
                            return const <PopupMenuEntry>[
                              PopupMenuItem(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('Votre avis'),
                                    Icon(Icons.star),
                                  ],
                                ),
                                value: '/rate',
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 320 * fem,
                    decoration: BoxDecoration(color: Colors.grey),
                    child: AnotherCarousel(
                      dotSize: 3 * fem,
                      dotSpacing: 10 * fem,
                      overlayShadow: true,
                      overlayShadowSize: 0.4,
                      dotBgColor: Colors.transparent,
                      autoplayDuration: Duration(seconds: 8),
                      animationDuration: Duration(milliseconds: 500),
                      images: imagesUrl.map((image) {
                        return NetworkImage(image);
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * fem,
                      vertical: 5 * fem,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              child: Text(
                                prdtName,
                                textAlign: TextAlign.left,
                                style: SafeGoogleFont(
                                  'Mulish',
                                  fontSize: 30 * ffem,
                                  fontWeight: FontWeight.w800,
                                  height: 1.255 * ffem / fem,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                price == 0 ? 'GRATUIT' : '$price FCFA',
                                textAlign: TextAlign.left,
                                style: SafeGoogleFont(
                                  'Mulish',
                                  fontSize: 25 * ffem,
                                  fontWeight: FontWeight.w800,
                                  height: 1.255 * ffem / fem,
                                  color: Color(0xfff49101),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              showRatingBar(context, prdtAndUser);
                            },
                            child: RatingBar.builder(
                              initialRating: rating,
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              ignoreGestures: true,
                              itemSize: 20,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        _division(fem, ffem, 'Description', description),
                        _division(fem, ffem, 'Localization', '${country.name} - $sellerRegion'),
                        _division(fem, ffem, 'Information du vendeur', ''),
                        // Divider(
                        //   color: Colors.black12,
                        //   thickness: 1,
                        // ),
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(
                        //     0 * fem,
                        //     0 * fem,
                        //     0 * fem,
                        //     5 * fem,
                        //   ),
                        //   child: Text(
                        //     'Information du vendeur',
                        //     style: SafeGoogleFont(
                        //       'Montserrat',
                        //       fontSize: 12 * ffem,
                        //       fontWeight: FontWeight.w800,
                        //       height: 1.3333333333 * ffem / fem,
                        //       letterSpacing: 0.400000006 * fem,
                        //       color: Color(0xff6d7d8b),
                        //     ),
                        //   ),
                        // ),
                        FilleulsCard(
                          isSub: true,
                          url: sellerUrl,
                          name: sellerName,
                          email: sellerEmail,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ReusableButton(
                          title: 'Contacter maintenant',
                          onPress: () {
                            launchURL(link);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _division(double fem, double ffem, title, description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: Colors.black12,
          thickness: 1,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
            0 * fem,
            0 * fem,
            0 * fem,
            5 * fem,
          ),
          child: Text(
            title,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w800,
              height: 1.3333333333 * ffem / fem,
              letterSpacing: 0.400000006 * fem,
              color: Color(0xff6d7d8b),
            ),
          ),
        ),
        Container(
          child: Text(
            description,
            textAlign: TextAlign.left,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w600,
              height: 1.5 * ffem / fem,
              color: Colors.grey,
            ),
          ),
        ),
        if(description != '')
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
