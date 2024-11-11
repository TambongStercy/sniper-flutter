import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import localization extension

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
  String password = '';
  String countryCode2 = 'CM';
  double balance = 0;
  bool isSubscribed = false;

  bool showSpinner = false;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
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
    balance = prefs.getDouble('balance') ?? 0;
    phone = prefs.getString('momo') ?? prefs.getString('phone') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    final country = getCountryFromPhoneNumber(phone);

    countryCode = country!.dialCode;
    countryCode2 = country.code;

    phone = phone.substring(country.dialCode.length);
  }

  Future<void> withdrawal(context) async {
    try {
      if (phone.isNotEmpty && amount.isNotEmpty) {
        final intAmt = int.parse(amount);
        final fee = intAmt * 0.05;

        final sendPone = countryCode + phone;

        if (!isSubscribed) {
          String msg = context.translate('not_subscribed');
          String title = context.translate('error');
          return showPopupMessage(context, title, msg);
        }

        if (intAmt > balance || balance < (intAmt + fee)) {
          String msg = context.translate('insufficient_balance');
          String title = context.translate('insufficient_funds');
          return showPopupMessage(context, title, msg);
        }

        if (intAmt < 250) {
          String msg = context.translate('low_amount');
          String title = context.translate('low_amount_title');
          return showPopupMessage(context, title, msg);
        }

        final regBody = {
          'email': email,
          'phone': sendPone,
          'amount': amount,
          'operator': dropdownValue,
          'password': password,
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
        final jsonResponse = jsonDecode(response.body);
        final msg = jsonResponse['message'] ?? '';

        if (response.statusCode == 200) {
          const title = 'Success';
          showPopupMessage(context, title, msg);
        } else {
          final title = context.translate('error');
          showPopupMessage(context, title, msg);
        }
      } else {
        String msg = context.translate('fill_all_fields');
        String title = context.translate('incomplete_info');
        showPopupMessage(context, title, msg);
      }
    } catch (e) {
      String msg = context.translate('error_occurred');
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: context.translate('withdrawal'),
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
                      context.translate('withdrawal_info'),
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
                          context.translate('operator'),
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
                        items: <String>['MTN', 'ORANGE']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 15 * fem),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 10 * fem),
                        child: Text(
                          context.translate('phone_number'),
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
                        hintText: context.translate('example_phone'),
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
                  SizedBox(height: 15 * fem),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 10 * fem),
                        child: Text(
                          context.translate('amount'),
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
                  SizedBox(height: 15 * fem),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 10 * fem),
                        child: Text(
                          context.translate('password'),
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
                        type: 3,
                        value: password,
                        onChange: (val) {
                          password = val;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15 * fem),
                  ReusableButton(
                    title: context.translate('confirm'),
                    onPress: () async {
                      setState(() {
                        showSpinner = true;
                      });

                      await withdrawal(context);

                      setState(() {
                        showSpinner = false;
                      });
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
