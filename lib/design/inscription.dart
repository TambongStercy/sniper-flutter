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
import 'package:snipper_frontend/components/button.dart'; // Ensure this import is present
import 'package:snipper_frontend/theme.dart'; // Add this import

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

      msg = response.message;

      if (response.apiReportedSuccess) {
        final responseData = response.body['data'];
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
        print('API Error registerUser: ${response.statusCode} - $msg');
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

      if (response.apiReportedSuccess && response.body['data'] != null) {
        final responseData = response.body['data'];
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
        final msg = response.message;
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
    final screenSize = MediaQuery.of(context).size;
    // final double expandedAppBarHeight = screenSize.height * 0.30; // No longer needed
    // final double collapsedAppBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top; // No longer needed

    return Scaffold(
      backgroundColor:
          Color(0xFFFFFFFF), // Light cream/off-white background for the page
      extendBodyBehindAppBar: true, // To allow gradient to go behind AppBar
      appBar: AppBar(
        // Simplified AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // No shadow
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          // Reverted to SingleChildScrollView
          child: Padding(
            padding: EdgeInsets.only(
                top: kToolbarHeight +
                    MediaQuery.of(context).padding.top +
                    20, // Initial top padding
                left: 24.0,
                right: 24.0,
                bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo at the top of the content body
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 30.0), // Adjust spacing as needed
                  child: Center(
                    child: Image.asset(
                      'assets/assets/images/logo-sbc-final-1-14d.png',
                      height: screenSize.height * 0.12, // Adjust logo size
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Text(
                  context.translate('create_account'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.translate('create_account_msg'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                // const SizedBox(height: 32), // Original spacing
                // const SizedBox(height: 32), // Increased spacing before form

                // All form fields and buttons remain here
                // Name field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('full_name'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.text,
                  hintText: context.translate('example_name'),
                  value: name,
                  onChange: (value) => setState(() => name = value),
                ),
                const SizedBox(height: 16),

                // Email field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('email'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.email,
                  hintText: context.translate('example_email'),
                  value: email,
                  onChange: (value) => setState(() => email = value),
                ),
                const SizedBox(height: 16),

                // Password field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('password'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.password,
                  hintText: context.translate('password'),
                  value: pw,
                  onChange: (value) => setState(() => pw = value),
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('confirm_password'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.password,
                  hintText: context.translate('confirm_password'),
                  value: pwconfirm,
                  onChange: (value) => setState(() => pwconfirm = value),
                ),
                const SizedBox(height: 16),

                // Phone field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('whatsapp_number'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.phone,
                  hintText: context.translate('example_whatsapp'),
                  initialCountryCode: countryCode,
                  value: whatsapp,
                  onChange: (value) => setState(() => whatsapp = value),
                  getCountryCode: (code) => setState(() => countryCode = code),
                ),
                const SizedBox(height: 16),

                // City field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('city'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.text,
                  hintText: context.translate('example_city'),
                  value: city,
                  onChange: (value) => setState(() => city = value),
                ),
                const SizedBox(height: 16),

                // Region field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('region'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.text,
                  hintText: context.translate('enter_region'),
                  value: region,
                  onChange: (value) => setState(() => region = value),
                ),
                const SizedBox(height: 16),

                // Date of Birth
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('date_of_birth'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.date,
                  hintText: context.translate('select_date_of_birth'),
                  currentDateValue: dob,
                  onDateSelected: (selectedDate) =>
                      setState(() => dob = selectedDate),
                ),
                const SizedBox(height: 16),

                // Sex selection
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('sex'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.dropdown,
                  hintText: context.translate('select_sex'),
                  items: sexOptions
                      .map((s) => {
                            'value': s,
                            'label': context.translate(s.toLowerCase())
                          })
                      .toList(),
                  selectedDropdownValue: sex,
                  onDropdownChanged: (value) => setState(() => sex = value),
                ),
                const SizedBox(height: 16),

                // Country selection
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('country'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.dropdown,
                  hintText: context.translate('select_country'),
                  items: africanCountries
                      .map((c) => {'value': c.code, 'label': c.name})
                      .toList(),
                  selectedDropdownValue: country,
                  onDropdownChanged: (value) => setState(() => country = value),
                ),
                const SizedBox(height: 16),

                // Profession selection
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('profession'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.dropdown,
                  hintText: context.translate('select_profession'),
                  items: allProfessions
                      .map((p) => {'value': p, 'label': p})
                      .toList(),
                  selectedDropdownValue: profession,
                  onDropdownChanged: (value) =>
                      setState(() => profession = value),
                ),
                const SizedBox(height: 16),

                // Language multi-select
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('language'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.multiSelect,
                  hintText: context.translate('all_languages'),
                  allOptions: allLanguages.map((l) => l['code']!).toList(),
                  selectedOptions: language,
                  displayMap: Map.fromEntries(allLanguages
                      .map((l) => MapEntry(l['code']!, l['name']!))),
                  onSaveMultiSelect: (selected) =>
                      setState(() => language = selected),
                ),
                const SizedBox(height: 16),

                // Interests multi-select
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('interests'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.multiSelect,
                  hintText: context.translate('all_interests'),
                  allOptions: allInterests.map((i) => i).toList(),
                  selectedOptions: interests,
                  displayMap: null,
                  onSaveMultiSelect: (selected) =>
                      setState(() => interests = selected),
                ),
                const SizedBox(height: 16),

                // Sponsor code field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    context.translate('sponsor_code'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[750],
                    ),
                  ),
                ),
                CustomTextField(
                  fieldType: CustomFieldType.text,
                  hintText: context.translate('sponsor_code'),
                  value: code,
                  onChange: (value) {
                    final newValue = value.trim();
                    if (newValue != code) {
                      setState(() {
                        code = newValue;
                        affiliationName = null; // Clear previous name
                      });
                      // Debounce for affiliation code
                      if (_debounceTimer?.isActive ?? false) {
                        _debounceTimer!.cancel();
                      }
                      _debounceTimer = Timer(Duration(milliseconds: 800), () {
                        if (newValue.isNotEmpty) {
                          fetchAffiliationName(newValue);
                        }
                      });
                    }
                  },
                ),

                // Show affiliate name if available
                if (affiliationName != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 8.0, bottom: 16.0),
                    child: Text(
                      '${context.translate('sponsor')}: $affiliationName',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Terms and conditions
                Row(
                  children: [
                    Checkbox(
                      value: termsAccepted,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        setState(() {
                          termsAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            termsAccepted = !termsAccepted;
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.translate('accept_terms_conditions'),
                                style: TextStyle(
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            TextButton(
                              onPressed: downloadPolicies,
                              child: Text(
                                context.translate('terms_conditions'),
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Register button
                ReusableButton(
                  title: context.translate('sign_up'),
                  onPress: () {
                    if (name.isEmpty ||
                        email.isEmpty ||
                        pw.isEmpty ||
                        pwconfirm.isEmpty ||
                        whatsapp.isEmpty ||
                        city.isEmpty ||
                        region.isEmpty ||
                        dob == null ||
                        sex == null ||
                        country == null ||
                        profession == null ||
                        language.isEmpty ||
                        interests.isEmpty) {
                      showPopupMessage(
                        context,
                        context.translate('information_incomplete'),
                        context.translate('fill_all_required_fields_dialog'),
                      );
                      return;
                    }

                    if (pw != pwconfirm) {
                      String errorTitle =
                          context.translate('false_confirmation');
                      String errorMessage =
                          context.translate('password_confirmation_error');
                      showPopupMessage(context, errorTitle, errorMessage);
                      return;
                    }

                    if (!termsAccepted) {
                      showPopupMessage(
                        context,
                        context.translate('information_incomplete'),
                        context.translate('accept_terms_conditions'),
                      );
                      return;
                    }

                    registerUser();
                  },
                  lite: false,
                  mh: 0, // To match splash1.dart and fill parent padding
                ),

                const SizedBox(height: 16),

                // Login button
                GestureDetector(
                  onTap: () => context.goNamed(Connexion.id),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text:
                            '${context.translate('already_have_account')}? ',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: context.translate('login'),
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ], // This closes the children of the inner Column
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmailDomain(String email) {
    // Split the email at @ and check the domain part
    final parts = email.split('@');
    if (parts.length != 2) return false; // Not a valid email format

    final domain = parts[1].toLowerCase();

    // List of common email domains to accept
    final validDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'live.com',
      'aol.com',
      'icloud.com',
      'mail.ru',
      'protonmail.com',
      'pm.me',
      'yandex.ru',
      'zoho.com',
      'gmx.com',
      'gmx.net',
      'tutanota.com',
      'msn.com',
      'comcast.net',
      'verizon.net',
      'sbcglobal.net',
      // Add other domains as needed
    ];

    return validDomains.any((valid) => domain.contains(valid)) ||
        domain.endsWith('.edu') ||
        domain.endsWith('.gov') ||
        domain.endsWith('.org') ||
        domain.endsWith('.net') ||
        domain.endsWith('.co') ||
        domain.endsWith('.io');
  }
}
