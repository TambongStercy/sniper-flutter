import 'dart:convert';
import 'dart:async'; // Import Timer

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/design/verify_registration.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:intl/intl.dart';
import 'package:snipper_frontend/design/profile-modify.dart'
    show allLanguages, sexOptions; // Import only needed options
import 'package:snipper_frontend/design/accueil.dart'
    show allProfessions, allInterests; // Import options
// Import the global countries list
import 'package:snipper_frontend/constants/countries.dart';
import 'package:snipper_frontend/components/textfield.dart'
    show CustomFieldType; // Import enum

class Inscription extends StatefulWidget {
  static const id = 'inscription';

  final String? affiliationCode;

  const Inscription({Key? key, this.affiliationCode}) : super(key: key);

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  String name = '';
  String email = '';
  String pw = '';
  String pwconfirm = '';
  String whatsapp = '';
  String countryCode = '237';
  String city = '';
  String region = '';
  String code = '';
  String? affiliationName;
  bool isFetchingAffiliation = false; // Track if fetching is in progress

  // New fields for registration
  DateTime? dob;
  String? sex;
  List<String> language = []; // For multi-select language
  String? country; // Store country code
  String? profession;
  List<String> interests = []; // For multi-select interests
  bool termsAccepted = false; // Renamed from 'check'
  bool showSpinner = false;
  bool isChanged = false;

  late SharedPreferences prefs;
  final ApiService _apiService = ApiService();

  String? userId; // Store userId from registration response
  bool showOtpScreen = false;
  String otp = '';

  // Add state variable for terms PDF ID
  String? termsPdfId;

  Timer? _debounceTimer; // Add timer variable

  Future<void> registerUser() async {
    setState(() {
      showSpinner = true;
    });
    String msg = '';

    try {
        if (!isValidEmailDomain(email.trim())) {
          String title = context.translate('invalid_email_domain');
          String message = context.translate('use_valid_email_provider');
          showPopupMessage(context, title, message);
        setState(() => showSpinner = false); // Stop spinner
          return;
        }

        final regBody = {
          'name': name,
          'email': email.trim(),
          'password': pw,
          'phoneNumber': (countryCode + whatsapp),
        'city': city,
        'region': region,
        if (code.isNotEmpty) 'referrerCode': code.trim(),
        'birthDate': DateFormat('yyyy-MM-dd').format(dob!),
          'sex': sex,
        'language': language,
          'country': country,
        'profession': profession,
        'interests': interests,
        };

        final response = await _apiService.registerUser(regBody);

      msg = response['message'] ??
          response['error'] ??
          'Unknown registration error';

      if (response['success'] == true) {
          final responseData = response['data'];
        final userId = responseData?['userId'];

        if (userId != null) {
          print("Registration Step 1 Success. UserID: $userId. Message: $msg");
          // Instead of showing OTP screen directly, navigate to VerifyRegistration
          // Store necessary info for verification screen (userId, email)
          // prefs.setString('pending_verification_userId', userId);
          // prefs.setString('pending_verification_email', email.trim());
          // Pass email and userId directly via 'extra'
          context.goNamed(
                VerifyRegistration.id,
                extra: {
                  'email': email.trim(),
                  'userId': userId,
                },
          ); // Go to verification page

          // Optionally show a success message before navigating
          // showPopupMessage(context, context.translate('registration_initiated'), msg);
        } else {
          print(
              "Error: Registration API returned 200 but missing userId. Response: $response");
          String errorTitle = context.translate('error');
          showPopupMessage(context, errorTitle,
              context.translate('registration_failed_unexpected'));
        }
      } else {
        String errorTitle = context.translate('error');
        showPopupMessage(context, errorTitle, msg);
        print('API Error registerUser: ${response['statusCode']} - $msg');
      }
    } catch (e) {
      print('Exception during registration: $e');
      String title = context.translate('error');
      showPopupMessage(context, title, context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  void downloadPolicies() {
    // Load the PDF ID from prefs (might be loaded in initState)
    final pdfId = prefs.getString('appSettings_termsPdfId');
    if (pdfId != null && pdfId.isNotEmpty) {
      final url = '$settingsFileBaseUrl$pdfId';
      print("Launching Terms URL: $url");
      launchURL(url);
    } else {
      print("Terms PDF ID not found in SharedPreferences.");
      // Optionally show an error message to the user
      showPopupMessage(context, context.translate('error'),
          context.translate('terms_not_available')); // Add translation
    }
    // launchURL(downloadPoliss); // Remove old static URL launch
  }

  @override
  void initState() {
    super.initState();
    // Load prefs and then fetch affiliation name
    _initializeAsyncData();
  }

  // Helper async function for initState
  Future<void> _initializeAsyncData() async {
    await initSharedPref();
    // Ensure prefs are loaded before fetching
    if (mounted) {
      // Check mounted after await
      // No need for addPostFrameCallback here, just call directly
      fetchAffiliationName(widget.affiliationCode ?? '');
    }
  }

  Future<void> initSharedPref() async {
    // Make it Future<void>
    prefs = await SharedPreferences.getInstance();
    code = widget.affiliationCode ?? '';
    // Load terms ID here for immediate use in downloadPolicies if needed
    termsPdfId = prefs.getString('appSettings_termsPdfId');
    print('affiliationCode: ');
    print(widget.affiliationCode);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  Future<void> fetchAffiliationName(String code) async {
    if (code.isEmpty) {
      setState(() {
        affiliationName = null;
      });
      return;
    }

    setState(() {
      isFetchingAffiliation = true; // Show progress indicator
      affiliationName = null; // Clear previous name while fetching
    });

    try {
      // Use ApiService
      final response = await _apiService.getAffiliationInfo(code);

      if (response['success'] == true && response['data'] != null) {
        final responseData = response['data'];
        // Assuming the backend returns the name directly in 'data' or nested like {'name': '...'}
        // Adjust key access based on actual API response
        final fetchedName = responseData is Map
            ? responseData['name'] as String?
            : responseData as String?;

        if (fetchedName != null && fetchedName.isNotEmpty) {
          setState(() {
            affiliationName = fetchedName; // Set the fetched name
          });
        } else {
          // Handle case where API succeeded but no name was found for the code
          setState(() {
            affiliationName =
                context.translate('code_not_found'); // Indicate not found
          });
        }
      } else {
        // Handle API error response
        final msg = response['message'] ??
            response['error'] ??
            'Failed to fetch affiliation info';
        print("API Error fetching affiliation: $msg");
        setState(() {
          affiliationName = context.translate('code_error'); // Indicate error
        });
      }
    } catch (e) {
      print('Exception fetching affiliation: $e');
      setState(() {
        affiliationName = context.translate('code_error'); // Indicate error
      });
    } finally {
      if (mounted) {
        setState(() {
          isFetchingAffiliation = false; // Hide progress indicator
        });
      }
    }
  }

  String? get affiliationCode => widget.affiliationCode;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            child: Container(
                width: double.infinity,
                color: const Color(0xffffffff),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          25 * fem, 0 * fem, 0 * fem, 21.17 * fem),
                      width: 771.27 * fem,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40.0),
                          Container(
                            margin: EdgeInsets.only(top: 46 * fem),
                            child: Text(
                              'Sniper Business Center',
                              textAlign: TextAlign.left,
                              style: SafeGoogleFont(
                                'Mulish',
                                fontSize: 30 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.255 * ffem / fem,
                                color: const Color(0xff000000),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 34 * fem),
                            child: Text(
                            context.translate('registration'), // 'Inscription'
                              textAlign: TextAlign.left,
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 20 * ffem,
                                fontWeight: FontWeight.w800,
                                height: 1 * ffem / fem,
                                color: const Color(0xfff49101),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 34 * fem),
                            child: Text(
                              context.translate(
                                  'create_account_msg'), // 'Créez un compte pour développez votre réseau...'
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 15 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.4 * ffem / fem,
                                color: const Color(0xff797979),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                              label: context.translate('full_name'),
                              hintText: context.translate('example_name'),
                                value: name,
                              onChange: (val) => name = val,
                              fieldType: CustomFieldType.text,
                              ),
                              CustomTextField(
                              label: 'Email',
                              hintText: context.translate('example_email'),
                                value: email,
                              onChange: (val) => email = val,
                              fieldType: CustomFieldType.email,
                              ),
                              CustomTextField(
                              label: context.translate('password'),
                              hintText: context.translate('password'),
                                value: pw,
                              onChange: (val) => pw = val,
                              fieldType: CustomFieldType.password,
                              ),
                              CustomTextField(
                              label: context.translate('confirm_password'),
                              hintText: context.translate('confirm_password'),
                                value: pwconfirm,
                              onChange: (val) => pwconfirm = val,
                              fieldType: CustomFieldType.password,
                              ),
                              CustomTextField(
                              label: context.translate('whatsapp_number'),
                              hintText: context.translate('example_whatsapp'),
                                value: whatsapp,
                              onChange: (val) => whatsapp = val,
                              getCountryDialCode: (code) => countryCode = code,
                              fieldType: CustomFieldType.phone,
                            ),
                            SizedBox(height: 8 * fem),
                              CustomTextField(
                              label: context.translate('city'),
                              hintText: context.translate('example_city'),
                                value: city,
                              onChange: (val) => city = val,
                              fieldType: CustomFieldType.text,
                            ),
                            SizedBox(height: 8 * fem),
                            CustomTextField(
                              label: context.translate('region'),
                              hintText: context.translate('example_region'),
                              value: region,
                              onChange: (val) => region = val,
                              fieldType: CustomFieldType.text,
                            ),
                            SizedBox(height: 8 * fem),
                            CustomTextField(
                              label: context.translate('date_of_birth'),
                              hintText:
                                  context.translate('select_date_of_birth'),
                              fieldType: CustomFieldType.date,
                              currentDateValue: dob,
                              onDateSelected: (date) =>
                                  setState(() => dob = date),
                            ),
                            SizedBox(height: 15 * fem),
                            CustomTextField(
                              label: context.translate('sex'),
                              hintText: context.translate('select_sex'),
                              fieldType: CustomFieldType.dropdown,
                              items: sexOptions
                                  .map((s) => {
                                        'value': s,
                                        'display':
                                            context.translate(s.toLowerCase())
                                      })
                                  .toList(),
                              selectedDropdownValue: sex,
                              onDropdownChanged: (newValue) =>
                                  setState(() => sex = newValue),
                              ),
                              SizedBox(height: 15 * fem),
                            CustomTextField(
                              label: context.translate('language'),
                              hintText: context.translate(
                                  'tap_to_select'), // Or similar hint
                              fieldType: CustomFieldType.multiSelect,
                              allOptions:
                                  allLanguages.map((l) => l['code']!).toList(),
                              selectedOptions: language,
                              onSaveMultiSelect: (selected) =>
                                  setState(() => language = selected),
                              displayMap: Map.fromIterables(
                                  allLanguages.map((l) => l['code']!),
                                  allLanguages.map((l) => l['name']!)),
                            ),
                            SizedBox(height: 15 * fem),
                            CustomTextField(
                              label: context.translate('country'),
                              hintText: context.translate('select_country'),
                              fieldType: CustomFieldType.dropdown,
                              items: africanCountries
                                  .map((c) =>
                                      {'value': c.code, 'display': c.name})
                                  .toList(),
                              selectedDropdownValue: country,
                              onDropdownChanged: (newValue) =>
                                  setState(() => country = newValue),
                              ),
                              SizedBox(height: 15 * fem),
                            CustomTextField(
                              label: context.translate('profession'),
                              hintText: context.translate('select_profession'),
                              fieldType: CustomFieldType.dropdown,
                              items: allProfessions
                                  .map((p) => {'value': p, 'display': p})
                                  .toList(),
                              selectedDropdownValue: profession,
                              onDropdownChanged: (newValue) =>
                                  setState(() => profession = newValue),
                              ),
                              SizedBox(height: 15 * fem),
                            CustomTextField(
                              label: context.translate('interests'),
                              hintText: context.translate(
                                  'tap_to_select'), // Or similar hint
                              fieldType: CustomFieldType.multiSelect,
                              allOptions: allInterests,
                              selectedOptions: interests,
                              onSaveMultiSelect: (selected) =>
                                  setState(() => interests = selected),
                              ),
                              SizedBox(height: 15 * fem),
                              CustomTextField(
                              label: context.translate('sponsor_code'),
                                hintText: 'EX: eG7iOp3',
                              value: code, // Use code directly
                                readOnly: affiliationCode != null &&
                                  affiliationCode!.isNotEmpty &&
                                    !isChanged,
                                onChange: (val) {
                                final currentCode = val.trim();
                                code =
                                    currentCode; // Update the local code variable immediately
                                isChanged = affiliationCode == null ||
                                    affiliationCode!.isEmpty ||
                                    currentCode != affiliationCode;

                                // Clear previous timer if it exists
                                _debounceTimer?.cancel();

                                // Clear name and hide indicator immediately if changed
                                if (isChanged && affiliationName != null) {
                                  setState(() {
                                    affiliationName = null;
                                    isFetchingAffiliation = false;
                                  });
                                }

                                // If code is empty or hasn't changed from initial, don't fetch
                                if (currentCode.isEmpty || !isChanged) {
                                  return;
                                }

                                // Start a new timer
                                _debounceTimer =
                                    Timer(const Duration(seconds: 3), () {
                                  // Check mounted again inside timer callback
                                  if (mounted) {
                                    fetchAffiliationName(currentCode);
                                  }
                                });
                              },
                              fieldType: CustomFieldType.text,
                            ),
                            if (isFetchingAffiliation)
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 4.0 * fem, left: 5.0 * fem),
                                child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              )
                            else if (affiliationName != null)
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 4.0 * fem, left: 5.0 * fem),
                                child: Text(
                                  affiliationName!,
                                  style: TextStyle(
                                    color: affiliationName ==
                                                context.translate(
                                                    'code_not_found') ||
                                            affiliationName ==
                                                context.translate('code_error')
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 12 * ffem,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                10 * fem, 20 * fem, 0 * fem, 0 * fem),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextButton(
                                  onPressed: downloadPolicies,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(
                                        20 * fem, 0 * fem, 10 * fem, 20 * fem),
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(0 * fem,
                                              0 * fem, 17 * fem, 0 * fem),
                                          width: 20 * fem,
                                          height: 20 * fem,
                                          child: Image.asset(
                                            'assets/design/images/pictureaspdf.png',
                                            width: 20 * fem,
                                            height: 20 * fem,
                                          ),
                                        ),
                                        Text(
                                          context.translate(
                                              'terms_conditions'), // 'Conditions generales d'utilisations'
                                          style: SafeGoogleFont(
                                            'Montserrat',
                                            fontSize: 16 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: const Color(0xff6d7d8b),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                    termsAccepted = !termsAccepted;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(
                                        20 * fem, 0 * fem, 20 * fem, 0 * fem),
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(0 * fem,
                                              0 * fem, 10 * fem, 0 * fem),
                                          width: 24 * fem,
                                          height: 24 * fem,
                                          child: Checkbox(
                                          value: termsAccepted,
                                          onChanged: (bool? value) {
                                              setState(() {
                                              termsAccepted = value ?? false;
                                              });
                                            },
                                          ),
                                        ),
                                        Text(
                                          context.translate(
                                              'accept_terms_conditions'), // 'J'accepte les termes et conditions'
                                          style: SafeGoogleFont(
                                            'Montserrat',
                                            fontSize: 16 * ffem,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5 * ffem / fem,
                                            color: const Color(0xff6d7d8b),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20 * fem),
                          ReusableButton(
                          clickable: termsAccepted,
                          title: context.translate('sign_up'), // 'Inscription'
                            lite: false,
                            onPress: () async {
                            String? validationError = _validateInputs();
                            if (validationError != null) {
                              String title = validationError ==
                                      context.translate(
                                          'password_confirmation_error')
                                  ? context.translate('false_confirmation')
                                  : context.translate('information_incomplete');
                              showPopupMessage(context, title, validationError);
                            } else if (!termsAccepted) {
                              showPopupMessage(
                                  context,
                                  context.translate('error'),
                                  context.translate(
                                      'accept_terms_conditions')); // Add translation key
                            } else if (code.isNotEmpty &&
                                (affiliationName ==
                                        context.translate('code_not_found') ||
                                    affiliationName ==
                                        context.translate('code_error'))) {
                              showPopupMessage(
                                  context,
                                  context.translate('error'),
                                  context.translate(
                                      'invalid_sponsor_code')); // Add translation key
                            } else {
                                await registerUser();
                              }
                            },
                          ),
                          SizedBox(height: 20 * fem),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                context.goNamed(Connexion.id);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                context.translate(
                                    'already_have_account_login'), // 'Un compte ? Connexion'
                                style: SafeGoogleFont(
                                  'Montserrat',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5 * ffem / fem,
                                  color: const Color(0xff25313c),
                                ),
                              ),
                            ),
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

  // --- Validation Logic ---
  String? _validateInputs() {
    if (name == null ||
            name!.isEmpty ||
            email == null ||
            email!.isEmpty ||
            pw == null ||
            pw!.isEmpty ||
            pwconfirm == null ||
            pwconfirm!.isEmpty ||
            whatsapp == null ||
            whatsapp!.isEmpty ||
            city == null ||
            city!.isEmpty ||
            region == null ||
            region!.isEmpty ||
            dob == null ||
            sex == null ||
            language.isEmpty ||
            country == null ||
            country!.isEmpty ||
            profession == null ||
            profession!.isEmpty ||
            interests.isEmpty
        // Sponsor code (code) is optional for initial validation, but checked later if provided
        ) {
      return context.translate('fill_all_information');
    }
    if (pw != pwconfirm) {
      return context.translate('password_confirmation_error');
    }
    if (!isValidEmailDomain(email!)) {
      return context.translate('use_valid_email_provider');
    }
    // Add more specific validation if needed (e.g., phone number format)
    return null; // No errors
  }
}
