import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/modify-product.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension

class YourProducts extends StatefulWidget {
  static const id = 'yourProduct';

  @override
  State<YourProducts> createState() => _YourProductsState();
}

class _YourProductsState extends State<YourProducts> {
  String email = '';
  String token = '';
  bool showSpinner = true;
  final List prdtList = [];
  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    token = prefs.getString('token') ?? '';
  }

  @override
  void initState() {
    super.initState();

    // Create anonymous function:
    () async {
      try {
        await getProductsOnline();

        showSpinner = false;
        refreshPage();
      } catch (e) {
        print(e);

        showSpinner = false;
        refreshPage();
      }
    }();
  }

  Future<void> refresh() async {
    prdtList.clear();
    showSpinner = true;
    refreshPage();

    await getProductsOnline();

    showSpinner = false;
    refreshPage();
  }

  Future<void> getProductsOnline() async {
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$findUrProduct?email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        final newItems = jsonResponse['products'];

        prdtList.addAll(newItems);

        setState(() {});
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
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> deleteThisProduct(String id) async {
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$deleteProduct?email=$email&id=$id');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        final newItems = jsonResponse['products'];

        prdtList.addAll(newItems);

        showPopupMessage(context, context.translate('success'), msg);

        setState(() {});
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
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  refreshPage() {
    if (mounted) {
      initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }
  }

  void showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: RichText(
            text: TextSpan(
              text: context.translate('delete_product_prompt'),
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: Color(0xff25313c),
              ),
              children: <TextSpan>[
                TextSpan(
                  text: context.translate('delete'),
                  style: TextStyle(color: Colors.red),
                ),
                TextSpan(
                  text: context.translate('delete_risk_notice'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  context.pop();
                  showSpinner = true;
                  refreshPage();
                  await deleteThisProduct(id);
                  await refresh();
                } catch (e) {
                  print(e);
                }
              },
              child: Text(
                context.translate('yes'),
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(context.translate('no')),
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
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: context.translate('your_products_services'),
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(5 * fem, 10 * fem, 5 * fem, 0 * fem),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: prdtList.length == 0
              ? [Text(context.translate('no_products_services'))]
              : prdtList.map((prdt) {
                  return prdtTile(prdt, fem, ffem);
                }).toList(),
        ),
      ),
    );
  }

  Widget prdtTile(prdt, double fem, double ffem) {
    final prdtName = prdt['name'];
    final id = prdt['id'];
    final price = prdt['price'] ?? 0;
    final imageUrl = prdt['urls'][0] ?? '';
    final rating = (prdt['overallRating'] ?? 0.0).toDouble();
    final ratingLength = (prdt['ratings'] ?? []).length;

    return Card(
      elevation: 1.0,
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 10 * fem),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 232, 255, 233),
          borderRadius: BorderRadius.circular(4 * fem),
        ),
        child: ListTile(
          contentPadding:
              EdgeInsets.fromLTRB(20 * fem, 0 * fem, 20 * fem, 0 * fem),
          leading: Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
            width: 35 * fem,
            height: 35 * fem,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5 * fem),
              color: Colors.black,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageUrl),
              ),
            ),
          ),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == '/edit') {
                context.pushNamed(ModifyProduct.id, extra: prdt).then((value) => refresh());
              } else if (value == '/delete') {
                showDeleteDialog(context, id);
              }
            },
            itemBuilder: (BuildContext bc) {
              return const <PopupMenuEntry>[
                PopupMenuItem(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Edit'),
                      Icon(Icons.edit),
                    ],
                  ),
                  value: '/edit',
                ),
                PopupMenuItem(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  value: '/delete',
                ),
              ];
            },
          ),
          title: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  prdtName,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 16 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1.0625 * ffem / fem,
                    letterSpacing: -0.5 * fem,
                    color: Color(0xff25313c),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: RatingBar.builder(
                  initialRating: rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ignoreGestures: true,
                  itemSize: 20,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '(${formatNumber(ratingLength)})',
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 13 * ffem,
                    fontWeight: FontWeight.w500,
                    height: 1.4166666667 * ffem / fem,
                    letterSpacing: -0.5 * fem,
                    color: Color(0xff6d7d8b),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            price > 0 ? '$price FCFA' : context.translate('free'),
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w500,
              height: 1.4166666667 * ffem / fem,
              letterSpacing: -0.5 * fem,
              color: Color(0xff6d7d8b),
            ),
          ),
        ),
      ),
    );
  }

  String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 10000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(0)}k';
    } else if (number < 10000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else {
      return '${(number / 1000000).toStringAsFixed(0)}M';
    }
  }
}
