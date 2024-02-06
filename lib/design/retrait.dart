import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';

class Retrait extends StatefulWidget {
  static const id = 'retrait';

  @override
  State<Retrait> createState() => _RetraitState();
}

class _RetraitState extends State<Retrait> {
  String dropdownValue = 'MTN';

  String phone = '';
  String amount = '';
  String token = '';
  String email = '';
  String countryCode = '237';
  String countryCode2 = 'CM';
  int balance = 0;
  bool isSubscribed = false;

  bool showSpinner = false;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    // Create anonymous function:
    () async {
      await initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token') ?? '';
    email = prefs.getString('email') ?? '';
    balance = prefs.getInt('balance') ?? 0;
    phone = prefs.getString('phone') ?? '';
    isSubscribed = prefs.getBool('isSubscribed')??false;

    final country = getCountryFromPhoneNumber(phone);

    countryCode = country!.dialCode;
    countryCode2 = country.code;

    phone = phone.substring(country.dialCode.length);

    print(prefs.getString('token'));
    // avatar = prefs.getString('avatar') ?? '';
    // isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  Future<void> withdrawal(context) async {
    try {
      if (phone.isNotEmpty && amount.isNotEmpty) {
        final intAmt = int.parse(amount);
        final fee = intAmt * 0.02;

        if(!isSubscribed){
          String msg =
              'Votre compte n\'es pas abonné ';
          String title = 'Pas Abonné';
          return showPopupMessage(context, title, msg);
        }

        if (intAmt > balance || balance < (intAmt + fee)) {
          String msg =
              'Votre compte n\'as pas assez d\'argent pour effectuer un retrait';
          String title = 'Solde Insuffisant';
          return showPopupMessage(context, title, msg);
        }

        if (intAmt < 50) {
          String msg = 'Vous devez retire au moins 50 FCFA';
          String title = 'Somme trop petit';
          return showPopupMessage(context, title, msg);
        }

        final regBody = {
          'email': email,
          'phone': phone,
          'amount': amount,
          'operator': dropdownValue,
        };

        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        final response = await http.post(
          Uri.parse(withdraw),
          headers: headers,
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 200) {
          final msg = 'you successfully withdrawed $amount from your wallet';
          const title = 'Success';

          showPopupMessage(context, title, msg);
        } else {
          const msg = 'an error occured please try again later';
          const title = 'Error';

          showPopupMessage(context, title, msg);
        }

        // print(msg);
      } else {
        String msg = 'Please fill in all information asked';
        String title = 'Information not complete';
        showPopupMessage(context, title, msg);
        print(msg);
      }
    } catch (e) {
      String msg = e.toString();
      String title = 'Error';
      print(msg);
      showPopupMessage(context, title, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SimpleScaffold(
      title: 'Retrait',
      inAsyncCall: showSpinner,
      child: Container(
        margin: EdgeInsets.fromLTRB(25 * fem, 20 * fem, 25 * fem, 14 * fem),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (email != '')
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 0 * fem, 20 * fem),
                    child: Text(
                      'Informations de retrait',
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 20 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1 * ffem / fem,
                        color: Color(0xfff49101),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 10 * fem),
                        child: Text(
                          'Operateur',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.4285714286 * ffem / fem,
                            color: Color(0xff25313c),
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        hint: Text(
                          dropdownValue,
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.4285714286 * ffem / fem,
                            color: Color(0xfff49101),
                          ),
                        ),
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffbbc8d4),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffbbc8d4),
                              width: 1,
                            ),
                          ),
                        ),
                        value: dropdownValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        // icon: const Icon(Icons.arrow_drop_down_rounded),
                        // iconSize: 60,
                        iconDisabledColor: Colors.blue,
                        iconEnabledColor: Colors.pink,
                        items: <String>[
                          'MTN',
                          'ORANGE',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 10 * fem),
                        child: Text(
                          'Numero de telephone',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.4285714286 * ffem / fem,
                            color: Color(0xff25313c),
                          ),
                        ),
                      ),
                      CustomTextField(
                        hintText: 'EX: 674090411',
                        value: phone,
                        onChange: (val) {
                          phone = val;
                        },
                        getCountryCode: (code) {
                          countryCode = code;
                        },
                        initialCountryCode: countryCode2,
                        margin: 0,
                        type: 5,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 10 * fem),
                        child: Text(
                          'Montant',
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.4285714286 * ffem / fem,
                            color: Color(0xff25313c),
                          ),
                        ),
                      ),
                      CustomTextField(
                        hintText: '',
                        value: amount,
                        onChange: (val) {
                          amount = val;
                        },
                        margin: 0,
                        type: 2,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  ReusableButton(
                    title: 'Valider',
                    onPress: () async {
                      try {
                        setState(() {
                          // Update your UI with the desired changes.
                          showSpinner = true;
                        });

                        await withdrawal(context);

                        setState(() {
                          // Update your UI with the desired changes.
                          showSpinner = false;
                        });
                      } on Exception catch (e) {
                        print(e);
                        setState(() {
                          // Update your UI with the desired changes.
                          showSpinner = false;
                        });
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
