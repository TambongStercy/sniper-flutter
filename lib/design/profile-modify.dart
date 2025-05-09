import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
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
import 'package:snipper_frontend/theme.dart';

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
      'SN': ['ORANGE_MOMO_SEN', 'FREE_MOMO_SEN', 'EXPRESSO_MOMO_SEN'],
      'CG': ['MTN_MOMO_COG', 'AIRTEL_MOMO_COG'],
      'GA': ['AIRTEL_MOMO_GAB', 'MOOV_MOMO_GAB'],
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          context.translate('modify'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: showSpinner
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: id != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Photo Section
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        final result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                          withData: kIsWeb,
                                        );

                                        if (result == null) return;

                                        final file = result.files.single;
                                        final String pathOrBase64 = kIsWeb
                                            ? base64.encode(file.bytes!)
                                            : file.path!;
                                        final String originalFileName =
                                            file.name;

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
                                        if (mounted && showSpinner)
                                          setState(() => showSpinner = false);
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[200],
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: profileImage(
                                                  prefs.getString('avatarId')),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryBlue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Form Section Title
                            Text(
                              context.translate('personal_info'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Personal Information Section
                            _buildEditableTextField(
                                context.translate('name'),
                                context.translate('name_example'),
                                name,
                                (val) => name = val),

                            _buildEditableTextField(
                                context.translate('city'),
                                context.translate('example_city'),
                                city,
                                (val) => city = val),

                            _buildPhoneField(
                              context.translate('whatsapp_number'),
                              phone,
                              countryCode2,
                              (val) => phone = val,
                              (code) => countryCode = code,
                              (cCode) {},
                            ),

                            _buildEditableTextField(context.translate('region'),
                                'Enter region', region, (val) => region = val),

                            _buildEditableTextField(
                                context.translate('sponsor_code'),
                                'Enter sponsor code',
                                code,
                                (val) => code = val),

                            _buildPhoneField(
                                context.translate('momo_number'),
                                momo ?? '',
                                cCode2,
                                (val) => momo = val,
                                (code) => cCode = code,
                                (country) => updateCorrespondents(country)),

                            _buildDropdownField(
                                context.translate('momo_correspondent'),
                                dropdownValue,
                                correspondents,
                                (val) => setState(() => dropdownValue = val!)),

                            _buildProfessionDropdown(),

                            _buildMultiSelectModalButton(
                                context.translate('language'),
                                allLanguages.map((l) => l['name']!).toList(),
                                language
                                    .map((code) => allLanguages.firstWhere(
                                        (l) => l['code'] == code,
                                        orElse: () => {'name': ''})['name']!)
                                    .where((name) => name.isNotEmpty)
                                    .toList(), (selectedNames) {
                              language = selectedNames
                                  .map((name) => allLanguages.firstWhere(
                                      (l) => l['name'] == name)['code']!)
                                  .toList();
                            }),

                            _buildMultiSelectModalButton(
                                context.translate('interests'),
                                allInterests,
                                interests,
                                (selected) => interests = selected),

                            _buildSwitchField(
                                context.translate('share_contact_info'),
                                shareContactInfo,
                                (val) => shareContactInfo = val),

                            _buildCountryDropdown(),

                            _buildSexDropdown(),

                            _buildDOBField(),

                            const SizedBox(height: 32),

                            // Submit Buttons Section
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: modifyUser,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text(
                                    context.translate('modify'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  showPopupMessage(
                                    context,
                                    context.translate('modify_email'),
                                    context.translate('email_modify_otp',
                                        args: {'email': email}),
                                    callback: () async {
                                      context.pushNamed(ModifyEmail.id);
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.primaryBlue),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text(
                                    context.translate('modify_email'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            context.translate('no_profile_data'),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ),
            ),
    );
  }

  // --- Helper Methods for Building Form Fields ---

  Widget _buildEditableTextField(String label, String hint,
      String? initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: hint,
            onChange: onChanged,
            margin: 0,
            value: initialValue,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(
      String label,
      String initialValue,
      String initialCountryCode,
      Function(String) onPhoneChanged,
      Function(String) onDialCodeChanged,
      Function(String) onCountryCodeChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String currentValue,
      List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: items.contains(currentValue) ? currentValue : items.first,
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('profession'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
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
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectModalButton(
    String label,
    List<String> allOptions,
    List<String> selectedOptions,
    Function(List<String>) onSave,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              _showMultiSelectModal(
                  context, label, allOptions, selectedOptions, onSave);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedOptions.isEmpty
                        ? context.translate('tap_to_select')
                        : context.translate('selected_count',
                            args: {'count': selectedOptions.length.toString()}),
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedOptions.isEmpty
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
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
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryBlue : null,
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
                ElevatedButton(
                  child: Text(context.translate('save')),
                  onPressed: () {
                    setState(() {
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

  Widget _buildSwitchField(
      String label, bool initialValue, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        trailing: Switch(
          value: initialValue,
          onChanged: (bool value) {
            setState(() {
              onChanged(value);
            });
          },
          activeColor: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('country'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: (country != null &&
                      africanCountries.any((c) => c.code == country))
                  ? country
                  : null,
              hint: Text(context.translate('select_country')),
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
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('sex'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: (sex != null && sexOptions.contains(sex)) ? sex : null,
              hint: Text(context.translate('select_sex')),
              items: sexOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(context.translate(value.toLowerCase())),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  sex = newValue;
                });
              },
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDOBField() {
    final TextEditingController _dobController = TextEditingController();
    DateTime? _selectedDate;

    if (dob != null) {
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(dob!);
        _dobController.text = DateFormat.yMMMd().format(_selectedDate);
      } catch (e) {
        print("Error parsing initial DOB: $e");
        _dobController.text = context.translate('invalid_date_format');
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('date_of_birth'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: context.translate('select_date_of_birth'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              suffixIcon:
                  Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.primaryBlue,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                  _dobController.text =
                      DateFormat.yMMMd().format(_selectedDate!);
                  dob = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
