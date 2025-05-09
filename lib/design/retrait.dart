import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String amount = '';
  String email = '';
  String momoNumber = '';
  String momoCor = '';
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
  final ApiService _apiService = ApiService();

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    () async {
      await initSharedPref();
      if (mounted) {
        setState(() {
          final country = getCountryFromPhoneNumber(momoNumber);
          if (country != null) {
            countryCode = country.dialCode;
            countryCode2 = country.code;
            updateOperatorsAndCurrencies(countryCode2); // Default to Cameroon
          }
        });
      }
    }();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    email = prefs.getString('email') ?? '';
    momoNumber = prefs.getString('momo') ?? '';
    momoCor = prefs.getString('momoCorrespondent') ?? '';
    balance = prefs.getDouble('balance') ?? 0;
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    final country = getCountryFromPhoneNumber(momoNumber);

    if (country != null) {
      countryCode = country.dialCode;
      countryCode2 = country.code;
    }
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

    final data = correspondents[countryCode];
    operators = data?['operators'] ?? ['MTN_MOMO_CMR', 'ORANGE_CMR'];
    availableCurrencies = data?['currencies'] ?? ['XAF'];
    dropdownValue = operators.contains(momoCor) ? momoCor : operators.first;
    selectedCurrency = availableCurrencies.first;
    if (mounted) {
      _updateConversionRate('1');
      setState(() {});
    }
  }

  Future<void> _updateConversionRate(String currentAmount) async {
    if (selectedCurrency == 'XAF') {
      setState(() {
        amountInXAF = double.tryParse(currentAmount) ?? 0;
      });
      return;
    }
    if (currentAmount.isEmpty || double.tryParse(currentAmount) == 0) {
      setState(() {
        amountInXAF = 0;
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await _apiService.convertCurrency(
            currentAmount, selectedCurrency, 'XAF');
        if (response['success'] == true && response['data'] != null) {
          final conversionData = response['data'];
          if (mounted) {
            setState(() {
              if (conversionData is Map &&
                  conversionData.containsKey('amount')) {
                amountInXAF =
                    (conversionData['amount'] as num?)?.toDouble() ?? 0.0;
              } else if (conversionData is num) {
                amountInXAF = conversionData.toDouble();
              } else {
                amountInXAF = 0.0;
                print("Unexpected conversion response format: $conversionData");
              }
            });
          }
        } else {
          print(
              "Currency conversion failed: ${response['message'] ?? response['error']}");
          if (mounted) {
            showPopupMessage(context, context.translate('error'),
                context.translate('currency_conversion_failed'));
            setState(() => amountInXAF = 0.0);
          }
        }
      } catch (e) {
        print('Error during currency conversion: $e');
        if (mounted) {
          showPopupMessage(context, context.translate('error'),
              context.translate('currency_conversion_failed'));
          setState(() => amountInXAF = 0.0);
        }
      }
    });
  }

  Future<void> requestWithdrawalOTP() async {
    setState(() {
      showSpinner = true;
    });
    try {
      if (amount.isEmpty || password.isEmpty || momoNumber.isEmpty) {
        throw Exception(context.translate('fill_all_fields'));
      }

      final doubleAmt = double.tryParse(amount);
      if (doubleAmt == null || doubleAmt <= 0) {
        throw Exception(context.translate('invalid_amount'));
      }

      final fee = doubleAmt * 0.05;

      if (!isSubscribed) {
        throw Exception(context.translate('not_subscribed'));
      }

      double checkAmountInXAF = amountInXAF;
      if (selectedCurrency != 'XAF' && checkAmountInXAF == 0 && doubleAmt > 0) {
        try {
          final convResponse = await _apiService.convertCurrency(
              amount, selectedCurrency, 'XAF');
          if (convResponse['success'] == true && convResponse['data'] != null) {
            final conversionData = convResponse['data'];
            if (conversionData is Map && conversionData.containsKey('amount')) {
              checkAmountInXAF =
                  (conversionData['amount'] as num?)?.toDouble() ?? 0.0;
            } else if (conversionData is num) {
              checkAmountInXAF = conversionData.toDouble();
            } else {
              throw Exception(context.translate('currency_conversion_failed'));
            }
          } else {
            throw Exception(context.translate('currency_conversion_failed'));
          }
        } catch (_) {
          throw Exception(context.translate('currency_conversion_failed'));
        }
      }
      if (checkAmountInXAF <= 0) {
        throw Exception(context.translate('invalid_conversion'));
      }

      if (checkAmountInXAF > balance || balance < (checkAmountInXAF + fee)) {
        throw Exception(context.translate('insufficient_balance'));
      }

      if (checkAmountInXAF < 250) {
        throw Exception(context.translate('low_amount'));
      }

      final withdrawalData = {
        'amount': amount,
        'operator': dropdownValue,
        'password': password,
        'currency': selectedCurrency,
      };

      final response = await _apiService.requestWithdrawalOtp(withdrawalData);
      final msg = response['message'] ?? response['error'] ?? '';

      if (response['success'] == true) {
        setState(() {
          otpRequested = true;
        });
        showPopupMessage(context, context.translate('success'), msg);
      } else {
        showPopupMessage(context, context.translate('error'), msg);
      }
    } catch (e) {
      String errorMsg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : context.translate('error_occurred');
      showPopupMessage(context, context.translate('error'), errorMsg);
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  Future<void> withdrawal() async {
    setState(() {
      showSpinner = true;
    });
    try {
      if (amount.isEmpty ||
          password.isEmpty ||
          otp.isEmpty ||
          otp.length != 6) {
        throw Exception(context.translate('fill_all_fields_otp'));
      }

      final doubleAmt = double.tryParse(amount);
      if (doubleAmt == null || doubleAmt <= 0) {
        throw Exception(context.translate('invalid_amount'));
      }
      final fee = doubleAmt * 0.05;
      if (!isSubscribed) {
        throw Exception(context.translate('not_subscribed'));
      }
      double checkAmountInXAF = amountInXAF;
      if (selectedCurrency != 'XAF' && checkAmountInXAF == 0 && doubleAmt > 0) {
        try {
          final convResponse = await _apiService.convertCurrency(
              amount, selectedCurrency, 'XAF');
          if (convResponse['success'] == true && convResponse['data'] != null) {
            final conversionData = convResponse['data'];
            if (conversionData is Map && conversionData.containsKey('amount')) {
              checkAmountInXAF =
                  (conversionData['amount'] as num?)?.toDouble() ?? 0.0;
            } else if (conversionData is num) {
              checkAmountInXAF = conversionData.toDouble();
            } else {
              throw Exception(context.translate('currency_conversion_failed'));
            }
          } else {
            throw Exception(context.translate('currency_conversion_failed'));
          }
        } catch (_) {
          throw Exception(context.translate('currency_conversion_failed'));
        }
      }
      if (checkAmountInXAF <= 0) {
        throw Exception(context.translate('invalid_conversion'));
      }
      if (checkAmountInXAF > balance || balance < (checkAmountInXAF + fee)) {
        throw Exception(context.translate('insufficient_balance'));
      }
      if (checkAmountInXAF < 250) {
        throw Exception(context.translate('low_amount'));
      }

      final withdrawalData = {
        'amount': amount,
        'operator': dropdownValue,
        'password': password,
        'currency': selectedCurrency,
        'otp': otp,
      };

      final response = await _apiService.confirmWithdrawal(withdrawalData);
      final msg = response['message'] ?? response['error'] ?? '';

      if (response['success'] == true) {
        setState(() {
          otpRequested = false;
          otp = '';
          amount = '';
          password = '';
        });
        _apiService.getUserProfile().then((profileResponse) {
          if (profileResponse['success'] == true &&
              profileResponse['data'] != null) {
            final fetchedBalance =
                (profileResponse['data']?['balance'] as num?)?.toDouble() ??
                    balance;
            prefs.setDouble('balance', fetchedBalance);
            if (mounted)
              setState(() => balance = fetchedBalance.floorToDouble());
          }
        });
        showPopupMessage(context, context.translate('success'), msg);
      } else {
        showPopupMessage(context, context.translate('error'), msg);
      }
    } catch (e) {
      String errorMsg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : context.translate('error_occurred');
      showPopupMessage(context, context.translate('error'), errorMsg);
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.translate('withdrawal'),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (email != '')
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              context.translate('withdrawal_info'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xfff49101),
                              ),
                            ),
                          ),

                          // Amount field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  context.translate('amount', args: {
                                    'currency': selectedCurrency,
                                    'momo': '${momoNumber} ${dropdownValue}',
                                    'conversion':
                                        '${selectedCurrency != 'XAF' ? '(${amountInXAF > 0 ? amountInXAF.toStringAsFixed(2) : '...'} XAF)' : ''}',
                                  }),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              CustomTextField(
                                hintText: '',
                                value: amount,
                                onChange: (val) {
                                  amount = val;
                                  _updateConversionRate(val);
                                },
                                margin: 0,
                                fieldType: CustomFieldType.number,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.0),

                          // Password field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  context.translate('password'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              CustomTextField(
                                hintText: '',
                                fieldType: CustomFieldType.password,
                                value: password,
                                onChange: (val) {
                                  password = val;
                                },
                              ),
                            ],
                          ),

                          // OTP field if requested
                          if (otpRequested) ...[
                            SizedBox(height: 24.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 12.0),
                                  child: Text(
                                    context
                                        .translate('enter_otp_for_withdrawal'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                OtpTextField(
                                  numberOfFields: 6,
                                  borderColor: Theme.of(context).primaryColor,
                                  fieldWidth: 40.0,
                                  margin: EdgeInsets.only(right: 8.0),
                                  showFieldAsBox: true,
                                  keyboardType: TextInputType.text,
                                  onCodeChanged: (String code) {},
                                  onSubmit: (String verificationCode) {
                                    otp = verificationCode;
                                  },
                                ),
                                SizedBox(height: 16.0),
                                Center(
                                  child: TextButton(
                                    onPressed: requestWithdrawalOTP,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      context.translate('resend_otp'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          SizedBox(height: 32.0),

                          // Action button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!otpRequested) {
                                  await requestWithdrawalOTP();
                                } else {
                                  await withdrawal();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                !otpRequested
                                    ? context.translate('request_otp')
                                    : context.translate('confirm_withdrawal'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
      ),
    );
  }
}
