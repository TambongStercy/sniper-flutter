import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

class Retrait extends StatefulWidget {
  static const id = 'retrait';

  @override
  State<Retrait> createState() => _RetraitState();
}

class _RetraitState extends State<Retrait> {
  String dropdownValue = 'MTN_MOMO_CMR';
  List<String> operators = ['MTN_MOMO_CMR', 'ORANGE_CMR'];
  String selectedCurrency = 'XAF';
  List<String> availableCurrencies = ['XAF'];

  String phone = '';
  String amount = '';
  String token = '';
  String email = '';
  String countryCode = '237';
  String password = '';
  String countryCode2 = 'CM'; // Default to Cameroon (2-letter country code)
  double amountInXAF = 0;
  double balance = 0;
  bool isSubscribed = false;
  bool otpRequested = false;
  String otp = '';

  bool showSpinner = false;

  late SharedPreferences prefs;

  // Declare the timer globally in your class
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    () async {
      await initSharedPref();
      setState(() {
        updateOperatorsAndCurrencies(countryCode2); // Default to Cameroon
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

  void updateOperatorsAndCurrencies(String countryCode) async {
    final correspondents = {
      'BJ': {
        'operators': ['MTN_MOMO_BEN', 'MOOV_BEN'], // Benin
        'currencies': ['XOF']
      },
      'CM': {
        'operators': ['MTN_MOMO_CMR', 'ORANGE_CMR'], // Cameroon
        'currencies': ['XAF']
      },
      'BF': {
        'operators': ['MOOV_BFA', 'ORANGE_BFA'], // Burkina Faso
        'currencies': ['XOF']
      },
      'CD': {
        'operators': ['VODACOM_MPESA_COD', 'AIRTEL_COD', 'ORANGE_COD'], // DRC
        'currencies': ['CDF']
      },
      'KE': {
        'operators': ['MPESA_KEN'], // Kenya
        'currencies': ['KES']
      },
      'NG': {
        'operators': ['MTN_MOMO_NGA', 'AIRTEL_NGA'], // Nigeria
        'currencies': ['NGN']
      },
      'SN': {
        'operators': ['FREE_SEN', 'ORANGE_SEN'], // Senegal
        'currencies': ['XOF']
      },
      'CG': {
        'operators': ['AIRTEL_COG', 'MTN_MOMO_COG'], // Republic of the Congo
        'currencies': ['XAF']
      },
      'GA': {
        'operators': ['AIRTEL_GAB'], // Gabon
        'currencies': ['XAF']
      },
      'CI': {
        'operators': ['MTN_MOMO_CIV', 'ORANGE_CIV'], // Côte d'Ivoire
        'currencies': ['XOF']
      },
    };

    operators = correspondents[countryCode]?['operators'] ??
        ['MTN_MOMO_CMR', 'ORANGE_CMR'];
    availableCurrencies = correspondents[countryCode]?['currencies'] ?? ['XAF'];
    dropdownValue = operators.first;
    selectedCurrency = availableCurrencies.first;
    amountInXAF = await convertCurrencyToXAF('1', selectedCurrency);
    setState(() {});
  }

  Future<double> convertCurrencyToXAF(String amount, String currency) async {
    try {
      // Construct the API URL
      final url =
          Uri.parse('${convertCurrency}?amount=$amount&from=$currency&to=XAF');

      // Send the GET request
      final response = await http.get(url);

      // Parse the response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return double.parse(jsonResponse['amount'].toString());
      } else {
        throw Exception(
            'Failed to convert currency. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during currency conversion: $e');
      throw Exception('Currency conversion failed');
    }
  }

  Future<void> requestWithdrawalOTP() async {
    try {
      if (phone.isNotEmpty && amount.isNotEmpty && password.isNotEmpty) {
        final intAmt = int.parse(amount);
        final fee = intAmt * 0.05;

        final sendPhone = countryCode + phone;

        if (!isSubscribed) {
          String msg = context.translate('not_subscribed');
          String title = context.translate('error');
          return showPopupMessage(context, title, msg);
        }

        // Convert the amount to XAF
        double amountInXAF =
            await convertCurrencyToXAF(amount, selectedCurrency);

        // Check if the balance is sufficient
        if (amountInXAF > balance || balance < (amountInXAF + fee)) {
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
          'phone': sendPhone,
          'amount': amount,
          'operator': dropdownValue,
          'password': password,
          'currency': selectedCurrency,
        };

        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        final response = await http.post(
          Uri.parse(requestPayoutOTP),
          headers: headers,
          body: jsonEncode(regBody),
        );
        final jsonResponse = jsonDecode(response.body);
        final msg = jsonResponse['message'] ?? '';

        if (response.statusCode == 200) {
          setState(() {
            otpRequested = true;
          });
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
      String msg = e.toString();
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> withdrawal() async {
    try {
      if (phone.isNotEmpty &&
          amount.isNotEmpty &&
          password.isNotEmpty &&
          otp.isNotEmpty) {
        final intAmt = int.parse(amount);
        final fee = intAmt * 0.05;

        final sendPhone = countryCode + phone;

        if (!isSubscribed) {
          String msg = context.translate('not_subscribed');
          String title = context.translate('error');
          return showPopupMessage(context, title, msg);
        }

        // Convert the amount to XAF
        double amountInXAF =
            await convertCurrencyToXAF(amount, selectedCurrency);

        // Check if the balance is sufficient
        if (amountInXAF > balance || balance < (amountInXAF + fee)) {
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
          'phone': sendPhone,
          'amount': amount,
          'operator': dropdownValue,
          'password': password,
          'currency': selectedCurrency,
          'otp': otp,
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
          setState(() {
            otpRequested = false;
            otp = '';
          });
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

    print(selectedCurrency);

    return SimpleScaffold(
      title: context.translate('withdrawal'),
      inAsyncCall: showSpinner,
      child: Container(
        margin: EdgeInsets.fromLTRB(25 * fem, 20 * fem, 25 * fem, 14 * fem),
        width: double.infinity,
        // decoration: const BoxDecoration(
        //   color: Color(0xffffffff),
        // ),
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
                        value: dropdownValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: operators
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
                        getCountryDialCode: (code) {
                          setState(() {
                            countryCode = code;
                          });
                        },
                        getCountryCode: (code) {
                          setState(() {
                            countryCode2 = code;
                            updateOperatorsAndCurrencies(code);
                          });
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
                          '${context.translate('amount')} in ${selectedCurrency} ${selectedCurrency != 'XAF' ? '(${amountInXAF.toStringAsFixed(2)} XAF = 1 ${selectedCurrency})' : ''}',
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
                  if (otpRequested) ...[
                    SizedBox(height: 15 * fem),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 10 * fem),
                          child: Text(
                            context.translate('enter_otp_for_withdrawal'),
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 14 * ffem,
                              fontWeight: FontWeight.w500,
                              height: 1.4285714286 * ffem / fem,
                              color: Color(0xff25313c),
                            ),
                          ),
                        ),
                        OtpTextField(
                          numberOfFields: 4,
                          borderColor: Color(0xFF512DA8),
                          fieldWidth: 50.0,
                          margin: EdgeInsets.only(right: 8.0),
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {
                            otp = code;
                          },
                          onSubmit: (String verificationCode) {
                            otp = verificationCode;
                          },
                        ),
                        SizedBox(height: 10 * fem),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              try {
                                setState(() {
                                  showSpinner = true;
                                });
                                await requestWithdrawalOTP();
                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                setState(() {
                                  showSpinner = false;
                                });
                                String msg =
                                    context.translate('error_occurred');
                                String title = context.translate('error');
                                showPopupMessage(context, title, msg);
                              }
                            },
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              context.translate('resend_otp'),
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.5 * ffem / fem,
                                color: limeGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 15 * fem),
                  ReusableButton(
                    title: context.translate('confirm'),
                    onPress: () async {
                      setState(() {
                        showSpinner = true;
                      });

                      if (!otpRequested) {
                        await requestWithdrawalOTP();
                      } else {
                        await withdrawal();
                      }

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
