import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/prodtpost.dart';
import 'package:snipper_frontend/components/rating_tag.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/produit-page.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart';

class Market extends StatefulWidget {
  Market({super.key, this.page});

  static const id = 'market';

  int? page;

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  final List prdtList = [];
  String email = '';
  String token = '';
  int itemCount = 0;
  int page = 1;
  bool hasMore = true;
  bool isSubscribed = false;
  bool isloading = false;

  late SharedPreferences prefs;

  final scrollController = ScrollController();
  String search = '';
  String queue = '';
  String category = '';
  String subcategory = '';
  double randNum = 0.5;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    token = prefs.getString('token') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  @override
  void initState() {
    super.initState();

    page = widget.page ?? page;

    final random = Random();
    randNum = random.nextDouble();

    getProductsOnline();

    scrollController.addListener(_onScroll);
  }

  
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.8) && hasMore) {
      getProductsOnline();
    }
  }

  Future<void> getProductsOnline() async {
    if (isloading) return;
    isloading = true;
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse(
          '$getProducts?email=$email&page=$page&search=$queue&category=$category&subcategory=$subcategory&randNum=$randNum');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        final newItems = jsonResponse['products'];
        page++;
        isloading = false;

        if (newItems.length < 10) {
          hasMore = false;
        }

        prdtList.addAll(newItems);
        itemCount = prdtList.length;

        if (mounted) setState(() {});
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

  Future<void> rateProduct(
      String sellerId, String prdtId, double rating) async {
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

      final title = (response.statusCode == 200)
          ? context.translate('success')
          : context.translate('error');

      showPopupMessage(context, title, msg);
      print(msg);
    } catch (e) {
      print(e);
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> refresh() async {
    final random = Random();
    double randomValue = random.nextDouble();

    print(randomValue);

    setState(() {
      prdtList.clear();
      itemCount = 0;
      page = 1;
      hasMore = true;
      randNum = randomValue;
    });

    getProductsOnline();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void showRatingBar(BuildContext context, prdtAndUser) {
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
            context.translate('product_rating_prompt'),
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
              onPressed: () async {
                try {
                  context.pop();
                  await rateProduct(sellerId, prdtId, userRating);
                } on Exception catch (e) {
                  print(e);
                }
              },
              child: Text(context.translate('ok')),
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(context.translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    List<String> subCategories = [];

    if (category == 'services') {
      subCategories.addAll(subServices);
    } else if (category == 'produits') {
      subCategories.addAll(subProducts);
    } else {
      final list = [...subProducts, ...subServices];
      subCategories.addAll(list.toSet().toList());
    }

    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
            color: Colors.grey[200],
            child: Column(
              children: [
                CustomTextField(
                  hintText: context.translate('search_product_or_service'),
                  onChange: (val) {
                    setState(() {
                      queue = val;
                    });
                  },
                  onSearch: () async {
                    await refresh();
                  },
                  searchMode: true,
                ),
                Row(
                  children: [
                    _topButton(fem, ''),
                    _topButton(fem, 'services'),
                    _topButton(fem, 'produits'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 45 * fem,
            padding: EdgeInsets.symmetric(vertical: 10 * fem),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: subCategories
                  .map((val) => _subcategButton(fem, val))
                  .toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemBuilder: ((context, index) {
                    final itemCount = prdtList.length;

                    if (index < itemCount) {
                      final prdtAndUser = prdtList[index];
                      final prdt = prdtAndUser['product'];
                      final link = prdt['whatsappLink'];
                      final prdtName = prdt['name'];
                      final price = prdt['price'] ?? 0;
                      final imageUrl = (prdt['urls'])[0];
                      final rating = (prdt['overallRating'] ?? 0.0).toDouble();
                      final ratingLength = (prdt['ratings'] ?? []).length;

                      final prdtId = prdt['id'];
                      final seller = prdtAndUser['userInfo'];
                      final sellerId = seller['id'];

                      return InkWell(
                        onTap: () {
                          context.pushNamed(
                            ProduitPage.id,
                            extra: prdtAndUser,
                          );
                        },
                        child: PrdtPost(
                          image: imageUrl,
                          onContact: () {
                            launchURL(link);
                          },
                          prdtId: prdtId,
                          sellerId: sellerId,
                          price: price,
                          title: prdtName,
                          rating: InkWell(
                            onTap: () {
                              showRatingBar(context, prdtAndUser);
                            },
                            child: RatingTag(
                              value: rating,
                              margin: EdgeInsets.all(3.0),
                              length: ratingLength,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(0),
                        child: Center(
                          child: hasMore
                              ? CircularProgressIndicator()
                              : Text(context.translate('no_more_products')),
                        ),
                      );
                    }
                  }),
                  itemCount: prdtList.length + 1,
                  padding: EdgeInsets.all(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InkWell _subcategButton(double fem, String subCateg) {
    subCateg = subCateg.toLowerCase();

    final value = subCateg == '' ? context.translate('all') : subCateg;

    return InkWell(
      onTap: () async {
        setState(() {
          subcategory = subCateg;
        });
        await refresh();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5 * fem,
          horizontal: 5 * fem,
        ),
        margin: EdgeInsets.symmetric(horizontal: 4 * fem),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10 * fem)),
          color: subcategory == subCateg ? blue : Colors.grey[200],
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: SafeGoogleFont(
            'Mulish',
            height: 1.255,
            fontSize: 12.0,
            color:
                subcategory == subCateg ? Color(0xffffffff) : Color(0xff000000),
          ),
        ),
      ),
    );
  }

  Expanded _topButton(double fem, String catg) {
    final value =
        catg == '' ? context.translate('all') : context.translate(catg);

    return Expanded(
      child: InkWell(
        onTap: () async {
          setState(() {
            category = catg;
            subcategory = '';
          });
          await refresh();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10 * fem,
            horizontal: 30 * fem,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10 * fem)),
            color: category == catg ? blue : null,
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'Mulish',
              height: 1.255,
              color: category == catg ? Color(0xffffffff) : Color(0xff000000),
            ),
          ),
        ),
      ),
    );
  }
}
