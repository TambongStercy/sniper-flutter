import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/design/modify-email.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/design/accueil.dart'
    show allProfessions, allInterests; // Import lists
import 'package:flutter/gestures.dart'; // Needed for multi-select
import 'package:intl/intl.dart'; // Import intl for date formatting
// Import the global countries list
import 'package:snipper_frontend/constants/countries.dart';

// Define language list (you might want to move this to a constants file)
final List<Map<String, String>> allLanguages = [
  {'code': 'en', 'name': 'English'},
  {'code': 'fr', 'name': 'Français'},
  // Add other supported languages here
];

// Define Sex options
final List<String> sexOptions = [
  'Male',
  'Female',
  'Other'
]; // Add translations if needed

class ProfileMod extends StatefulWidget {
  static const id = 'profile-modify';

  @override
  State<ProfileMod> createState() => _ProfileModState();
}

class _ProfileModState extends State<ProfileMod> {
  late SharedPreferences prefs;
  bool showSpinner = false;

  String dropdownValue = 'MTN_MOMO_CMR';
  List<String> correspondents = ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'];
  final ApiService _apiService = ApiService();

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    id = prefs.getString('id');
    email = prefs.getString('email') ?? '';
    name = prefs.getString('name');
    region = prefs.getString('region');
    city = prefs.getString('city');
    code = prefs.getString('code');
    phone = prefs.getString('phone') ?? '';
    momo = prefs.getString('momo');
    dropdownValue = prefs.getString('momoCorrespondent') ?? 'MTN_MOMO_CMR';
    avatar = prefs.getString('avatar') ?? "";

    // Load new fields
    dob = prefs.getString('dob');
    sex = prefs.getString('sex');
    language = prefs.getStringList('language') ?? [];
    country = prefs.getString('country');
    profession = prefs.getString('profession');
    interests = prefs.getStringList('interests') ?? [];
    shareContactInfo = prefs.getBool('shareContactInfo') ?? true;

    final country1 = getCountryFromPhoneNumber(phone);

    if (country1 != null) {
      countryCode = country1.dialCode;
      countryCode2 = country1.code;
      phone = phone.substring(country1.dialCode.length);
    } else {
      // Handle case where phone number might be invalid or empty
      print("Warning: Could not parse country code from phone number: $phone");
    }

    if (momo != null && momo!.isNotEmpty) {
      // Check if momo is not null and not empty
      final country2 = getCountryFromPhoneNumber(momo!);

      if (country2 != null) {
        cCode = country2.dialCode;
        cCode2 = country2.code;
        momo = momo?.substring(country2.dialCode.length);

        // Update correspondents based on the country code
        final correspondentMap = {
          'BJ': ['MTN_MOMO_BEN', 'MOOV_MOMO_BEN'],
          'CM': ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'],
          'BF': ['ORANGE_MOMO_BFA', 'MOOV_MOMO_BFA'],
          'CD': ['AIRTEL_MOMO_COD', 'VODACOM_MOMO_COD', 'ORANGE_MOMO_COD'],
          'KE': ['SAFARICOM_MOMO_KEN'],
          'NG': ['MTN_MOMO_NGA', 'AIRTEL_MOMO_NGA'],
          'SN': ['ORANGE_MOMO_SEN', 'FREE_MOMO_SEN', 'EXPRESSO_MOMO_SEN'],
          'CG': ['MTN_MOMO_COG', 'AIRTEL_MOMO_COG'],
          'GA': ['AIRTEL_MOMO_GAB', 'MOOV_MOMO_GAB'],
          'CI': ['MTN_MOMO_CIV', 'MOOV_MOMO_CIV', 'ORANGE_MOMO_CIV'],
        };

        correspondents = correspondentMap[country2.code] ??
            ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'];

        // Ensure dropdownValue is in the correspondents list
        if (!correspondents.contains(dropdownValue)) {
          dropdownValue = correspondents.first;
        }
      }
    } else {
      // Handle case where momo number is null or empty
      // Optionally set default correspondents or leave as is
      correspondents = ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'];
      dropdownValue = correspondents.first;
    }

    // Ensure spinner is handled correctly, maybe set to false after loading?
    // showSpinner = false; // Consider setting spinner state here
  }

  String? id;
  String email = '';
  String? name;
  String? region;
  String? city;
  String phone = '';
  String? momo = '';
  String cCode = '237';
  String cCode2 = 'CM';
  String? code;
  String avatar = '';
  String countryCode = '237';
  String countryCode2 = 'CM';

  // New state variables for display
  String? dob; // Store as String for display
  String? sex;
  List<String> language = [];
  String? country;
  String? profession;
  List<String> interests = [];
  bool shareContactInfo = true;

  void updateCorrespondents(String countryCode) {
    final correspondentMap = {
      'BJ': ['MTN_MOMO_BEN', 'MOOV_MOMO_BEN'], // Benin
      'CM': ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'], // Cameroon
      'BF': ['ORANGE_MOMO_BFA', 'MOOV_MOMO_BFA'], // Burkina Faso
      'CD': [
        'AIRTEL_MOMO_COD',
        'VODACOM_MOMO_COD',
        'ORANGE_MOMO_COD'
      ], // Congo (DRC)
      'KE': ['SAFARICOM_MOMO_KEN'], // Kenya
      'NG': ['MTN_MOMO_NGA', 'AIRTEL_MOMO_NGA'], // Nigeria
      'SN': [
        'ORANGE_MOMO_SEN',
        'FREE_MOMO_SEN',
        'EXPRESSO_MOMO_SEN'
      ], // Senegal
      'CG': ['MTN_MOMO_COG', 'AIRTEL_MOMO_COG'], // Congo-Brazzaville
      'GA': ['AIRTEL_MOMO_GAB', 'MOOV_MOMO_GAB'], // Gabon
      'CI': [
        'MTN_MOMO_CIV',
        'MOOV_MOMO_CIV',
        'ORANGE_MOMO_CIV'
      ], // Côte d'Ivoire
    };

    setState(() {
      correspondents =
          correspondentMap[countryCode] ?? ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'];
      // Make sure dropdownValue is in the correspondents list
      if (!correspondents.contains(dropdownValue)) {
        dropdownValue = correspondents.first;
      }
    });
  }

  Future<void> modifyUser() async {
    String msg = '';
    setState(() {
      showSpinner = true;
    });
    try {
      // Basic validation (adjust as needed for new fields)
      if (name == null ||
          name!.isEmpty ||
          region == null ||
          region!.isEmpty ||
          phone.isEmpty ||
              // code == null || // Sponsor code is likely not sent in update
              // code!.isEmpty ||
              city == null ||
              city!.isEmpty || // Added city validation
              profession == null ||
              profession!.isEmpty // Added profession validation
          ) {
        throw Exception(context.translate('fill_required_fields'));
      }

      final sendPone = countryCode + phone;
      // Handle null or empty momo number gracefully
      final sendMomo = (momo == null || momo!.isEmpty) ? null : cCode + momo!;

      final updateBody = {
        // 'id': id, // Not needed for /users/me endpoint
        // 'email': email, // Email likely cannot be changed here
        'name': name,
        'region': region,
        'city': city,
        'phoneNumber': sendPone,
        if (sendMomo != null) ...{
          'momoNumber': sendMomo,
          'momoOperator': dropdownValue,
        } else ...{
          'momoNumber': null,
          'momoOperator': null,
        },
        'referralCode':
            code, // Referral code might not be updatable, but sending if changed
        'language': language,
        'profession': profession,
        'interests': interests,
        'shareContactInfo': shareContactInfo,
        // Add newly editable fields
        'country': country, // Added country (send code)
        'sex': sex, // Added sex
        'birthDate':
            dob, // Added dob (formatted as YYYY-MM-DD, assuming API expects 'birthDate')
      };

      // Remove null values from body before sending
      updateBody.removeWhere((key, value) => value == null);

      final response = await _apiService.updateUserProfile(updateBody);
      msg = response['message'] ?? response['error'] ?? '';

      final title =
          (response['statusCode'] == 200 && response['success'] == true)
              ? context.translate('success')
              : context.translate('error');

      // Update SharedPreferences on success
      if (response['statusCode'] == 200 && response['success'] == true) {
        if (name != null) prefs.setString('name', name!); // Update name
        if (region != null) prefs.setString('region', region!); // Update region
        prefs.setString('phone', sendPone); // Update full phone
        if (sendMomo != null) {
          prefs.setString('momo', sendMomo); // Update full momo
          prefs.setString(
              'momoCorrespondent', dropdownValue); // Update operator
        } else {
          prefs.remove('momo');
          prefs.remove('momoCorrespondent');
        }
        // Code might not be updated, depends on backend logic
        if (code != null) prefs.setString('code', code!);

        // Save new fields
        if (city != null) prefs.setString('city', city!);
        prefs.setStringList('language', language);
        if (profession != null) prefs.setString('profession', profession!);
        prefs.setStringList('interests', interests);
        prefs.setBool('shareContactInfo', shareContactInfo);
        // Save newly editable fields to prefs
        if (country != null) prefs.setString('country', country!);
        if (sex != null) prefs.setString('sex', sex!);
        if (dob != null) prefs.setString('dob', dob!); // Save dob
      }

      showPopupMessage(context, title, msg);
      print(msg);
    } catch (e) {
      print("Error modifying user: $e");
      msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : context.translate('error_occurred');
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  Future<void> uploadAvatar({
    required BuildContext context,
    required String path, // This is base64 string on web, file path on mobile
    required String originalFileName, // Needed for mobile
  }) async {
    setState(() {
      showSpinner = true;
    });
    try {
      // Generate a unique filename for web to avoid caching issues, use original for mobile path
      final String fileName =
          kIsWeb ? generateUniqueFileName('pp', 'jpg') : originalFileName;

      final response = await _apiService.uploadAvatar(path, fileName);

      if (response['statusCode'] == 200 && response['success'] == true) {
        // Assuming the backend returns the new avatar URL upon success
        // Need to confirm the response structure from backend/userflow
        final responseData = response['data'];
        final newAvatarUrl =
            responseData?['avatarUrl'] as String? ?? // Check common keys
                responseData?['url'] as String? ??
                response['url'] as String?; // Example keys

        if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
          avatar =
              newAvatarUrl; // Update local state with the new URL from backend
          prefs.setString('avatar', newAvatarUrl); // Save the URL
          setState(() {});
          showPopupMessage(context, context.translate('success'),
              response['message'] ?? 'Avatar updated successfully.');
        } else {
          // Handle cases where upload succeeded but URL wasn't returned as expected
          print("Avatar uploaded, but URL not found in response: ${response}");
          showPopupMessage(context, context.translate('warning'),
              'Avatar uploaded, but failed to refresh display.');
          // Optionally, try reloading the profile to get the URL
        }
      } else {
        final msg = response['message'] ??
            response['error'] ??
            'Failed to upload avatar.';
        showPopupMessage(context, context.translate('error'), msg);
      }
    } catch (e) {
      print("Exception during avatar upload: $e");
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    showSpinner = true; // Start with spinner
    () async {
      await initSharedPref();
      if (mounted) {
        setState(() {
          showSpinner = false; // Stop spinner after loading
        });
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: context.translate('modify'), // 'Modifier'
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(25 * fem, 32 * fem, 25 * fem, 32 * fem),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: SingleChildScrollView(
          // Wrap content in SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    EdgeInsets.fromLTRB(1 * fem, 0 * fem, 1 * fem, 15 * fem),
                width: double.infinity,
                child: id != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 122 * fem,
                                  height: 122 * fem,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(61 * fem),
                                    border: Border.all(
                                      color: Color(0xffffffff),
                                      width: 2.0,
                                    ),
                                    color: Color(0xffc4c4c4),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: profileImage(
                                          avatar), // Uses util function
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 0 * fem, 7 * fem),
                                  child: Text(
                                    email, // Display email
                                    style: SafeGoogleFont(
                                      'Montserrat',
                                      fontSize: 12 * ffem,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3333333333 * ffem / fem,
                                      letterSpacing: 0.400000006 * fem,
                                      color: Color(0xff6d7d8b),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0 * fem,
                                ),
                                ReusableButton(
                                  title: context.translate(
                                      'modify_photo'), // 'Modifier Photo'
                                  onPress: () async {
                                    try {
                                      final result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.image,
                                        withData:
                                            kIsWeb, // Read bytes only on web
                                      );

                                      if (result == null) return;

                                      final file = result.files.single;
                                      final String pathOrBase64 = kIsWeb
                                          ? base64.encode(file.bytes!)
                                          : file.path!;
                                      final String originalFileName = file.name;

                                      await uploadAvatar(
                                        context: context,
                                        path: pathOrBase64,
                                        originalFileName: originalFileName,
                                      );
                                    } catch (e) {
                                      print("File picking/upload error: $e");
                                      if (mounted) {
                                        showPopupMessage(
                                            context,
                                            context.translate('error'),
                                            context.translate(
                                                'error_picking_file'));
                                      }
                                      // Ensure spinner is stopped if error occurs before upload call
                                      if (mounted && showSpinner)
                                        setState(() => showSpinner = false);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15 * fem,
                          ),
                          // --- Modifiable Fields ---
                          _buildEditableTextField(
                                  fem,
                                  ffem,
                              context.translate('name'),
                              context.translate('name_example'),
                              name,
                              (val) => name = val),
                          _buildEditableTextField(
                                  fem,
                                  ffem,
                              context.translate('city'),
                              context.translate('example_city'),
                              city,
                              (val) => city = val),
                          _buildPhoneField(
                                fem,
                                ffem,
                              context.translate('whatsapp_number'),
                              phone,
                              countryCode2,
                              (val) => phone = val,
                              (code) => countryCode = code,
                              (cCode) {}), // No country update for WhatsApp #
                          _buildEditableTextField(
                                  fem,
                                  ffem,
                              context.translate('region'),
                              'Enter region',
                              region,
                              (val) => region = val),
                          _buildEditableTextField(
                              fem,
                              ffem,
                              context.translate('sponsor_code'),
                              'Enter sponsor code',
                              code,
                              (val) => code = val),
                          _buildPhoneField(
                              fem,
                              ffem,
                              context.translate('momo_number'),
                              momo ?? '',
                              cCode2,
                              (val) => momo = val,
                              (code) => cCode = code,
                              (country) => updateCorrespondents(country)),
                          _buildDropdownField(
                              fem,
                              ffem,
                              context.translate('momo_correspondent'),
                              dropdownValue,
                              correspondents,
                              (val) => setState(() => dropdownValue = val!)),
                          _buildProfessionDropdown(fem, ffem),
                          _buildMultiSelectModalButton(
                              fem,
                              ffem,
                              context.translate('language'),
                              allLanguages
                                  .map((l) => l['name']!)
                                  .toList(), // All available names
                              language
                                  .map((code) => allLanguages.firstWhere(
                                      (l) => l['code'] == code,
                                      orElse: () => {'name': ''})['name']!)
                                  .where((name) => name.isNotEmpty)
                                  .toList(), // Currently selected names
                              (selectedNames) {
                            // Convert back to codes when saving
                            language = selectedNames
                                .map((name) => allLanguages.firstWhere(
                                    (l) => l['name'] == name)['code']!)
                                .toList();
                          }),
                          _buildMultiSelectModalButton(
                              fem,
                              ffem,
                              context.translate('interests'),
                              allInterests,
                              interests,
                              (selected) => interests = selected),
                          _buildSwitchField(
                              fem,
                              ffem,
                              context.translate('share_contact_info'),
                              shareContactInfo,
                              (val) => shareContactInfo = val),

                          // --- NEW Editable Fields for Country, Sex, DOB ---
                          _buildCountryDropdown(fem, ffem),
                          _buildSexDropdown(fem, ffem),
                          _buildDOBField(fem, ffem),
                          // --- End NEW Fields ---

                          SizedBox(height: 15 * fem),
                          ReusableButton(
                            title: context.translate('modify'), // 'Modifier'
                            lite: false,
                            onPress: modifyUser,
                          ),
                          SizedBox(
                            height: 15 * fem,
                          ),
                          ReusableButton(
                            title: context.translate(
                                'modify_email'), // 'Modifier l'adresse e-mail'
                            lite: false,
                            onPress: () async {
                              showPopupMessage(
                                context,
                                context.translate('modify_email'),
                                context.translate('email_modify_otp',
                                    args: {'email': email}),
                                callback: () async {
                                  await sendOTP();
                                  context.pushNamed(ModifyEmail.id);
                                },
                              );
                            },
                          ),
                        ],
                      )
                    : const SizedBox(), // Show empty space if id is null
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendOTP() async {
    // No longer needs id if endpoint relies on token
    // if (id != null && id!.isNotEmpty) {
    setState(() {
      showSpinner = true;
    });
    try {
      final response =
          await _apiService.requestEmailChangeOtp(); // Use new method
      final msg = response['message'] ??
          response['error'] ??
          context.translate('otp_request_failed');

      if (response['success'] == true) {
        showPopupMessage(context, context.translate('otp_sent'), msg);
        // Optionally return true or handle navigation based on success
      } else {
        showPopupMessage(context, context.translate('error'), msg);
      }
    } catch (e) {
      print("Error sending email change OTP: $e");
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
    // } else {
    //   showPopupMessage(context, context.translate('error'),
    //       context.translate('user_id_missing'));
    // }
  }

  // --- Helper Methods for Building Form Fields ---

  Widget _buildEditableTextField(double fem, double ffem, String label,
      String hint, String? initialValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, label),
        CustomTextField(
          hintText: hint,
          onChange: onChanged,
          margin: 0,
          value: initialValue,
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  Widget _buildPhoneField(
      double fem,
      double ffem,
      String label,
      String initialValue,
      String initialCountryCode,
      Function(String) onPhoneChanged,
      Function(String) onDialCodeChanged,
      Function(String) onCountryCodeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, label),
        CustomTextField(
          hintText: '',
          onChange: onPhoneChanged,
          getCountryDialCode: onDialCodeChanged,
          getCountryCode: onCountryCodeChanged,
          initialCountryCode: initialCountryCode,
          margin: 0,
          value: initialValue,
          fieldType: CustomFieldType.phone,
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  Widget _buildDropdownField(double fem, double ffem, String label,
      String currentValue, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, label),
        DropdownButtonFormField<String>(
          value: items.contains(currentValue) ? currentValue : items.first,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 5 * fem),
          ),
          isExpanded: true,
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  Widget _buildProfessionDropdown(double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, context.translate('profession')),
        DropdownButtonFormField<String>(
          value: (profession != null && allProfessions.contains(profession))
              ? profession
              : null,
          hint: Text(context.translate('select_profession')),
          items: allProfessions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              profession = newValue;
            });
          },
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 5 * fem),
          ),
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  // New helper for modal multi-select
  Widget _buildMultiSelectModalButton(
    double fem,
    double ffem,
    String label,
    List<String> allOptions,
    List<String> selectedOptions,
    Function(List<String>) onSave,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, label),
        InkWell(
          onTap: () {
            _showMultiSelectModal(
                context, label, allOptions, selectedOptions, onSave);
          },
          child: Container(
          width: double.infinity,
          padding:
              EdgeInsets.symmetric(horizontal: 12 * fem, vertical: 15 * fem),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8 * fem),
            border: Border.all(color: Colors.grey[400]!),
          ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedOptions.isEmpty
                      ? context
                          .translate('tap_to_select') // Add translation key
                      : context.translate('selected_count', args: {
                          'count': selectedOptions.length.toString()
                        }), // Add key
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 14 * ffem,
                    color: selectedOptions.isEmpty
                        ? Colors.grey[600]
                        : Color(0xff25313c),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  void _showMultiSelectModal(
    BuildContext context,
    String title,
    List<String> allOptions,
    List<String> initialSelection,
    Function(List<String>) onSave,
  ) {
    List<String> currentSelection = List.from(initialSelection);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: allOptions.map((option) {
                      final bool isSelected = currentSelection.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setDialogState(() {
                            if (selected) {
                              currentSelection.add(option);
                            } else {
                              currentSelection
                                  .removeWhere((item) => item == option);
                            }
                          });
                        },
                        selectedColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        checkmarkColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(context.translate('cancel')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(context.translate('save')), // Add translation key
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    setState(() {
                      // Update the parent state
                      onSave(currentSelection);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchField(double fem, double ffem, String label,
      bool initialValue, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: initialValue,
      onChanged: (bool value) {
        setState(() {
          onChanged(value);
        });
      },
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(context).colorScheme.primary,
    );
    // Add SizedBox(height: 15 * fem) after calling this if needed
  }

  // New helper for Country Dropdown
  Widget _buildCountryDropdown(double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, context.translate('country')),
        DropdownButtonFormField<String>(
          value: (country != null &&
                  africanCountries.any((c) => c.code == country))
              ? country
              : null,
          hint:
              Text(context.translate('select_country')), // Add translation key
          items: africanCountries.map((CountryInfo countryInfo) {
            return DropdownMenuItem<String>(
              value: countryInfo.code,
              child: Text(countryInfo.name),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              country = newValue;
            });
          },
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 5 * fem),
          ),
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  // New helper for Sex Dropdown
  Widget _buildSexDropdown(double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, context.translate('sex')),
        DropdownButtonFormField<String>(
          value: (sex != null && sexOptions.contains(sex)) ? sex : null,
          hint: Text(context.translate('select_sex')), // Add translation key
          items: sexOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(context.translate(value
                      .toLowerCase()) // Translate options like 'male', 'female'
                  ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              sex = newValue;
            });
          },
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 5 * fem),
          ),
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  // New helper for DOB Field with Date Picker
  Widget _buildDOBField(double fem, double ffem) {
    // Controller to display the formatted date
    final TextEditingController _dobController = TextEditingController();
    // Store the selected DateTime object separately
    DateTime? _selectedDate;

    // Initialize date if dob exists
    if (dob != null) {
      try {
        _selectedDate = DateFormat('yyyy-MM-dd')
            .parse(dob!); // Assuming ISO format YYYY-MM-DD
        _dobController.text =
            DateFormat.yMMMd().format(_selectedDate!); // Format for display
      } catch (e) {
        print("Error parsing initial DOB: $e");
        _dobController.text =
            context.translate('invalid_date_format'); // Show error
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, context.translate('date_of_birth')),
        TextField(
          controller: _dobController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: context
                .translate('select_date_of_birth'), // Add translation key
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 15 * fem),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900), // Set a reasonable lower bound
              lastDate: DateTime.now(), // Cannot select future date
            );
            if (pickedDate != null && pickedDate != _selectedDate) {
              setState(() {
                _selectedDate = pickedDate;
                // Format for display
                _dobController.text = DateFormat.yMMMd().format(_selectedDate!);
                // Format for saving (YYYY-MM-DD for backend/prefs)
                dob = DateFormat('yyyy-MM-dd').format(_selectedDate!);
              });
            }
          },
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  Container _label(double fem, double ffem, String title) {
    return Container(
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 7 * fem),
      child: Text(
        title,
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 12 * ffem,
          fontWeight: FontWeight.w500,
          height: 1.3333333333 * ffem / fem,
          letterSpacing: 0.400000006 * fem,
          color: Color(0xff6d7d8b),
        ),
      ),
    );
  }
}
