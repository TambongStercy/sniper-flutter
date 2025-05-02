import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart'; // Import ApiService
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/accueil-divertissement.dart';
import 'package:snipper_frontend/design/accueil-home.dart';
import 'package:snipper_frontend/design/accueil-investissement.dart';
import 'package:snipper_frontend/design/accueil-market.dart';
import 'package:snipper_frontend/design/accueil-publier.dart';
import 'package:snipper_frontend/design/add-product.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/design/produit-page.dart';
import 'package:snipper_frontend/design/profile-info.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/your-products.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension
import 'package:intl/intl.dart'; // For DateFormat if needed later
import 'package:flutter/gestures.dart'; // Needed for multi-select

// Define lists for profession and interests (populate from new.txt)
// TODO: Add translations for these if needed
final List<String> allProfessions = [
  'Médecin',
  'Infirmier/Infirmière',
  'Pharmacien',
  'Chirurgien',
  'Psychologue',
  'Dentiste',
  'Kinésithérapeute',
  'Ingénieur civil',
  'Ingénieur en informatique',
  'Développeur de logiciels',
  'Architecte',
  'Technicien en électronique',
  'Data scientist',
  'Enseignant',
  'Professeur d\'université',
  'Formateur professionnel',
  'Éducateur spécialisé',
  'Conseiller pédagogique',
  'Artiste (peintre, sculpteur)',
  'Designer graphique',
  'Photographe',
  'Musicien',
  'Écrivain',
  'Réalisateur',
  'Responsable marketing',
  'Vendeur/Vendeuse',
  'Gestionnaire de produit',
  'Analyste de marché',
  'Consultant en stratégie',
  'Avocat',
  'Notaire',
  'Juge',
  'Huissier de justice',
  'Chercheur scientifique',
  'Biologiste',
  'Chimiste',
  'Physicien',
  'Statisticien',
  'Travailleur social',
  'Conseiller en orientation',
  'Animateur socioculturel',
  'Médiateur familial',
  'Maçon',
  'Électricien',
  'Plombier',
  'Charpentier',
  'Architecte d\'intérieur',
  'Chef cuisinier',
  'Serveur/Serveuse',
  'Gestionnaire d\'hôtel',
  'Barman/Barmane',
  'Conducteur de train',
  'Pilote d\'avion',
  'Logisticien',
  'Gestionnaire de chaîne d\'approvisionnement',
  'Administrateur système',
  'Spécialiste en cybersécurité',
  'Ingénieur réseau',
  'Consultant en technologies de l\'information',
  'Journaliste',
  'Rédacteur web',
  'Chargé de communication',
  'Community manager',
  'Comptable',
  'Analyste financier',
  'Auditeur interne',
  'Conseiller fiscal',
  'Agriculteur/Agricultrice',
  'Ingénieur agronome',
  'Écologiste',
  'Gestionnaire de ressources naturelles',
  'Étudiant/Élève',
  'Autre'
];

final List<String> allInterests = [
  'Football', 'Basketball', 'Course à pied', 'Natation', 'Yoga', 'Randonnée',
  'Cyclisme',
  'Musique (instruments, chant)', 'Danse', 'Peinture et dessin', 'Photographie',
  'Théâtre', 'Cinéma',
  'Programmation', 'Robotique', 'Sciences de la vie', 'Astronomie',
  'Électronique',
  'Découverte de nouvelles cultures', 'Randonnées en nature',
  'Tourisme local et international',
  'Cuisine du monde', 'Pâtisserie', 'Dégustation de vins',
  'Aide aux personnes défavorisées', 'Protection de l\'environnement',
  'Participation à des événements caritatifs',
  'Lecture', 'Méditation', 'Apprentissage de nouvelles langues',
  'Jeux vidéo', 'Jeux de société', 'Énigmes et casse-têtes',
  'Stylisme', 'Décoration d\'intérieur', 'Artisanat',
  'Fitness', 'Nutrition', 'Médecine alternative',
  // Add 'Autre' (Other) if needed
];

// Define language list (consistent with profile-modify.dart)
final List<Map<String, String>> allLanguages = [
  {'code': 'en', 'name': 'English'},
  {'code': 'fr', 'name': 'Français'},
  // Add other supported languages here
];

// Define preference categories (using allInterests as placeholder)
// TODO: Replace with actual preference category list if different from interests
final List<String> allPreferenceCategories = List.from(allInterests);

class Accueil extends StatefulWidget {
  // static const id = 'accueil';

  final String? prdtId;
  final String? sellerId;

  const Accueil({Key? key, this.prdtId, this.sellerId}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 2;
  late List<Widget> _pages;
  int _homeVersion = 0;

  String avatar = '';
  String token = '';
  String id = '';
  String email = '';
  String name = '';
  bool isSubscribed = false;
  bool isPartner = false;
  bool showSpinner = true;
  bool mandatoryInfoNeeded = false; // Flag to track if popup is needed

  // New fields to store user data
  String? dob;
  String? sex;
  List<String> language = []; // CHANGE: Initialize as empty List<String>
  String? country;
  String? profession;
  List<String> interests = []; // Store as list of strings

  String countryCode = '237';
  String? momoNumber; // Renamed from 'momo', made nullable
  String? momoCor = 'MTN_MOMO_CMR'; // Made nullable
  List<String> correspondents = ['MTN_MOMO_CMR', 'ORANGE_CMR'];

  // Add state variables for dynamic settings
  String? appLogoUrl;
  String? termsPdfId;
  String? presentationPdfId;
  String? presentationVideoId;
  String? telegramUrl;
  String? whatsappUrl;

  late SharedPreferences prefs;
  TextEditingController phoneNumberController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instantiate ApiService

  get sellerId => widget.sellerId;
  get prdtId => widget.prdtId;

  @override
  void initState() {
    super.initState();

    _selectedIndex = (prdtId != null && sellerId != null) ? 3 : 2;

    _pages = <Widget>[
      const Publicite(),
      const Divertissement(),
      Home(changePage: onItemTapped),
      Market(),
      const Investissement(),
    ];

    () async {
      try {
        await getInfos(); // This now also checks for mandatory info

        // If info is needed, the dialog will show. If not, proceed.
        if (!mandatoryInfoNeeded) {
          if (prdtId != null && sellerId != '') {
            final prdtAndUser = await getProductOnline(sellerId, prdtId);
            if (prdtAndUser != null && mounted) {
              context.pushNamed(
                ProduitPage.id,
                extra: prdtAndUser,
              );
            }
          }
          // Comment out the call to the apology popup
          // showOneTimeApologyPopup();
        }

        showSpinner = false;
        refreshPage();
      } catch (e) {
        print(e);
        showSpinner = false;
        refreshPage();
      }
    }();
  }

  void showOneTimeApologyPopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showOneTimePopup(
        context,
        context.translate('apology_title') ?? 'We Apologize',
        context.translate('apology_message') ??
            'We sincerely apologize for the app being down for so long. We have resolved the issues and are committed to providing you with better service moving forward. Thank you for your patience and understanding.',
        'apology_popup_shown_v1', // Unique key for this popup
      );
    });
  }

  refreshPage() {
    if (mounted) {
      _pages = <Widget>[
        const Publicite(),
        const Divertissement(),
        Home(
          changePage: onItemTapped,
          key: ValueKey<int>(_homeVersion),
        ),
        Market(),
        const Investissement(),
      ];

      setState(() {
        // Update your UI with the desired changes.
      });
    }
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    id = prefs.getString('id') ?? '';
    email = prefs.getString('email') ?? '';
    name = prefs.getString('name') ?? '';
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    // Load new fields
    dob = prefs.getString('dob');
    sex = prefs.getString('sex');
    language =
        prefs.getStringList('language') ?? []; // CHANGE: Read as String List
    country = prefs.getString('country');
    profession = prefs.getString('profession');
    interests = prefs.getStringList('interests') ?? [];

    // Load App Settings from Prefs (they might be loaded later by getInfos/getAppSettings)
    appLogoUrl = prefs.getString('appSettings_logoUrl'); // Store full URL now
    termsPdfId = prefs.getString('appSettings_termsPdfId');
    presentationPdfId = prefs.getString('appSettings_presentationPdfId');
    presentationVideoId = prefs.getString('appSettings_presentationVideoId');
    telegramUrl = prefs.getString('appSettings_telegramUrl');
    whatsappUrl = prefs.getString('appSettings_whatsappUrl');

    // *** Update loading logic for renamed variables ***
    momoNumber =
        prefs.getString('momo'); // Load 'momo' pref into momoNumber state
    momoCor = prefs.getString('momoCorrespondent');
    // ************************************************

    // -- This check is now redundant here, will be done after API fetch in getInfos --
    // mandatoryInfoNeeded =
    //     (profession == null || profession!.isEmpty || interests.isEmpty);
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void>? getInfos() async {
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      // If mandatory info is needed, show the dialog immediately
      if (mandatoryInfoNeeded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showMandatoryInfoDialog();
        });
        return;
      }

      // Use ApiService to get user profile
      final response = await _apiService.getUserProfile();

      if (response['statusCode'] == 200 && response['success'] == true) {
        final responseData = response['data'] as Map<String, dynamic>?;

        if (responseData != null) {
          // --- Extract fields directly from responseData ---
          final fetchedName = responseData['name'] as String?;
          final region = responseData['region'] as String?;
          final country = responseData['country'] as String?;
          final phone = responseData['phoneNumber']?.toString();
          final fetchedMomoNumber = responseData['momoNumber']?.toString();
          final fetchedMomoCorrespondent =
              responseData['momoOperator'] as String?; // Use momoOperator
          final userEmail = responseData['email'] as String?;
          final fetchedAvatar = responseData['avatar'] as String?;
          final avatarId = responseData['avatarId'] as String?;
          final userRole = responseData['role'] as String?;
          final userCode =
              responseData['referralCode'] as String?; // Use referralCode
          final balance = (responseData['balance'] as num?)?.toDouble();
          final totalBenefits = (responseData['totalBenefits'] as num?)
              ?.toDouble(); // Use totalBenefits
          final fetchedDob = responseData['birthDate'] as String?;
          final fetchedSex = responseData['sex'] as String?;
          final List<String> fetchedLanguageList = List<String>.from(
              responseData['language'] as List<dynamic>? ?? []);
          final List<String> fetchedInterests = List<String>.from(
              responseData['interests'] as List<dynamic>? ?? []);
          final fetchedProfession = responseData['profession'] as String?;
          final List<dynamic> activeSubscriptions =
              responseData['activeSubscriptions'] as List<dynamic>? ?? [];
          final derivedIsSubscribed =
              activeSubscriptions.isNotEmpty; // Derive isSubscribed

          // --- Update local state variables ---
          name = fetchedName ?? name; // Use fetched or keep existing
          isSubscribed = derivedIsSubscribed;
          avatar = fetchedAvatar ?? avatar;
          // Update other state vars if needed for immediate UI changes before prefs save
          dob = fetchedDob ?? dob;
          sex = fetchedSex ?? sex;
          language = fetchedLanguageList.isNotEmpty
              ? fetchedLanguageList
              : language; // CHANGE: Assign list directly
          this.country =
              country ?? this.country; // Use the extracted country variable
          profession = fetchedProfession ?? profession;
          interests =
              fetchedInterests.isNotEmpty ? fetchedInterests : interests;

          // *** Update state assignment for renamed variables ***
          momoNumber = fetchedMomoNumber ?? momoNumber; // Update state
          momoCor = fetchedMomoCorrespondent ?? momoCor; // Update state
          // ************************************************

          // --- Save all fields to SharedPreferences ---
          prefs.setString('name', name);
          if (region != null) prefs.setString('region', region);
          if (country != null) prefs.setString('country', country);
          if (phone != null) prefs.setString('phone', phone);
          prefs.setString(
              'momo', momoNumber ?? ''); // Use momoNumber, provide default ''
          prefs.setString('momoCorrespondent',
              momoCor ?? ''); // Use momoCor, provide default ''
          if (userEmail != null)
            prefs.setString('email', userEmail); // Save email from profile
          if (fetchedAvatar != null) prefs.setString('avatar', fetchedAvatar);
          if (avatarId != null) prefs.setString('avatarId', avatarId);
          if (userRole != null) prefs.setString('role', userRole);
          if (userCode != null) prefs.setString('code', userCode);
          if (balance != null) prefs.setDouble('balance', balance);
          if (totalBenefits != null)
            prefs.setDouble(
                'benefit', totalBenefits); // Save totalBenefits as benefit
          if (fetchedDob != null) prefs.setString('dob', fetchedDob);
          if (fetchedSex != null) prefs.setString('sex', fetchedSex);
          prefs.setStringList('language', fetchedLanguageList); // Save as list
          if (fetchedProfession != null)
            prefs.setString('profession', fetchedProfession);
          prefs.setStringList('interests', fetchedInterests); // Save as list
          prefs.setBool(
              'isSubscribed', derivedIsSubscribed); // Save derived value
          prefs.setStringList('activeSubscriptions',
              activeSubscriptions.map((s) => s.toString()).toList());

          // --- NEW Comprehensive Mandatory Info Check ---
          bool isLanguageMissing = language.isEmpty;
          bool isInterestsMissing = interests.isEmpty;
          bool isDobMissing = dob == null || dob!.isEmpty;
          bool isProfessionMissing = profession == null || profession!.isEmpty;

          mandatoryInfoNeeded = isLanguageMissing ||
              isInterestsMissing ||
              isDobMissing ||
              isProfessionMissing;

          if (mandatoryInfoNeeded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showMandatoryInfoDialog();
            });
            return; // Stop further processing until info is provided
          }

          // Partner logic removed as it's not in /users/me response
          isPartner = false;
          prefs.remove('partnerAmount');
          prefs.remove('partnerPack');

          // --- Handle Subscription Redirect ---
          if (!isSubscribed) {
            if (mounted) context.goNamed(Subscrition.id);
            return; // Prevent further execution if redirecting
          }

          // --- Momo Number Dialog ---
          if (momoNumber == null ||
              momoNumber!.isEmpty ||
              momoCor == null ||
              momoCor!.isEmpty) {
            _showPhoneNumberDialog();
          }

          _homeVersion++; // Refresh Home widget if necessary
          refreshPage();
        } else {
          print(
              "Error: 'data' field missing or null in successful profile response.");
          // Handle case where success is true but data is missing
          msg = context.translate('fetch_profile_error_data');
          showPopupMessage(context, context.translate('error'), msg);
        }
      } else {
        // Handle errors returned by ApiService
        msg = response['message'] ?? response['error'] ?? 'Unknown error';
        final statusCode = response['statusCode'];

        if (statusCode == 401) {
          // Specific handling for unauthorized
          String title = context.translate('error_access_denied');
          showPopupMessage(context, title, msg);

          if (!kIsWeb) {
            await deleteFile(avatar);
          }

          prefs.clear();
          await deleteNotifications();
          await deleteAllKindTransactions();

          if (mounted) context.go('/');
        } else {
          String title = context.translate('error');
          showPopupMessage(context, title, msg);
        }
      }

      // Fetch app settings after profile info
      await _fetchAndSaveAppSettings();
    } catch (e) {
      print('Error in getInfos: $e');
      String title = context.translate('error');
      // Use a generic error message if msg wasn't set from API response
      String displayMessage =
          msg.isNotEmpty ? msg : context.translate('error_occurred');
      showPopupMessage(context, title, displayMessage);
    }
  }

  // --- Mandatory Info Dialog ---
  void _showMandatoryInfoDialog() {
    // Initialize state for the dialog
    String currentProfession = profession ?? '';
    List<String> currentInterests = List.from(interests);
    List<String> currentLanguages = List.from(language);
    String? currentDob = dob; // Keep as string YYYY-MM-DD
    DateTime? _selectedDate; // For the DatePicker
    final TextEditingController _dobController = TextEditingController();

    // Initialize date picker state if dob exists
    if (currentDob != null && currentDob.isNotEmpty) {
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(currentDob);
        _dobController.text =
            DateFormat.yMMMd().format(_selectedDate!); // Format for display
      } catch (e) {
        print("Error parsing initial DOB for dialog: $e");
        _dobController.text = context.translate('invalid_date_format');
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false, // User must fill this
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage dialog's internal state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context
                  .translate('complete_your_profile')), // Add translation
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context
                        .translate('please_provide_info')), // Add translation
                    SizedBox(height: 20),

                    // --- Profession --- (Dropdown)
                    _buildDialogFieldLabel(context.translate('profession')),
                    DropdownButtonFormField<String>(
                      value: currentProfession.isNotEmpty &&
                              allProfessions.contains(currentProfession)
                          ? currentProfession
                          : null,
                      hint: Text(context.translate('select_profession')),
                      items: allProfessions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          currentProfession = newValue ?? '';
                        });
                      },
                      isExpanded: true,
                      decoration: _dialogInputDecoration(),
                    ),
                    SizedBox(height: 15),

                    // --- Date of Birth --- (DatePicker)
                    _buildDialogFieldLabel(context.translate('date_of_birth')),
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: _dialogInputDecoration().copyWith(
                        hintText: context.translate('select_date_of_birth'),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null && pickedDate != _selectedDate) {
                          setDialogState(() {
                            _selectedDate = pickedDate;
                            _dobController.text = DateFormat.yMMMd()
                                .format(_selectedDate!); // Display format
                            currentDob = DateFormat('yyyy-MM-dd')
                                .format(_selectedDate!); // Save format
                          });
                        }
                      },
                    ),
                    SizedBox(height: 15),

                    // --- Languages --- (Multi-select Chips - Corrected)
                    _buildDialogFieldLabel(context.translate('language')),
                    _buildDialogFilterChips(
                        allLanguages
                            .map((l) => l['code']!)
                            .toList(), // Pass codes as options
                        currentLanguages, // Pass selected codes directly
                        (optionCode, selected) {
                      // Callback receives code
                      setDialogState(() {
                        if (selected) {
                          currentLanguages.add(optionCode);
                        } else {
                          currentLanguages.remove(optionCode);
                        }
                      });
                    },
                        displayMap: Map.fromIterables(
                            // Map codes to display names
                            allLanguages.map((l) => l['code']!),
                            allLanguages.map((l) => l['name']!))),
                    SizedBox(height: 15),

                    // --- Interests --- (Multi-select Chips)
                    _buildDialogFieldLabel(context.translate('interests')),
                    _buildDialogFilterChips(allInterests, currentInterests,
                        (option, selected) {
                      setDialogState(() {
                        if (selected) {
                          currentInterests.add(option);
                        } else {
                          currentInterests.remove(option);
                        }
                      });
                    }),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(context.translate('save')), // Add translation
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    // --- Validation for ALL required fields ---
                    if (currentProfession.isEmpty ||
                        currentDob == null ||
                        currentDob!.isEmpty ||
                        currentLanguages.isEmpty ||
                        currentInterests.isEmpty) {
                      showPopupMessage(
                          context,
                          context.translate('error'),
                          context.translate(
                              'fill_all_required_fields_dialog') // Use a specific message
                          );
                      return;
                    }
                    Navigator.of(context).pop(); // Close the dialog
                    // Call save with all collected data
                    _saveMandatoryInfo(currentProfession, currentInterests,
                        currentLanguages, currentDob! // Pass DOB string
                        );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper for dialog field labels
  Widget _buildDialogFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Helper for dialog input decoration
  InputDecoration _dialogInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      isDense: true, // Make fields compact
    );
  }

  // Helper for filter chips within the dialog (Updated Signature)
  Widget _buildDialogFilterChips(
      List<String> allOptions, // Now expects codes for language
      List<String> selectedOptions, // Now expects codes for language
      Function(String option, bool selected) onSelected,
      {Map<String, String>? displayMap} // Optional map for display names
      ) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: allOptions.map((option) {
        final bool isSelected = selectedOptions.contains(option);
        final String displayLabel =
            displayMap?[option] ?? option; // Use displayMap if provided
        return FilterChip(
          label:
              Text(displayLabel), // Display name from map or the option itself
          selected: isSelected,
          onSelected: (bool selected) {
            onSelected(option,
                selected); // Pass back the actual option (code for language)
          },
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
          labelStyle: TextStyle(
            fontSize: 12, // Smaller font for chips
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
          materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // Reduce tap area
          padding: EdgeInsets.symmetric(
              horizontal: 6, vertical: 2), // Adjust padding
        );
      }).toList(),
    );
  }

  // --- Save Mandatory Info --- (Modified Signature)
  Future<void> _saveMandatoryInfo(
      String newProfession,
      List<String> newInterests,
      List<String> newLanguages, // Added
      String newDob // Added (YYYY-MM-DD format)
      ) async {
    setState(() {
      showSpinner = true; // Show spinner while saving
    });

    try {
      // Save to SharedPreferences FIRST
      await prefs.setString('profession', newProfession);
      await prefs.setStringList('interests', newInterests);
      await prefs.setStringList('language', newLanguages); // Save languages
      await prefs.setString('dob', newDob); // Save DOB

      // Update local state optimistically
      profession = newProfession;
      interests = newInterests;
      language = newLanguages;
      dob = newDob;
      mandatoryInfoNeeded = false; // Mark as complete locally

      // Call backend endpoint to update user profile using ApiService
      final updateBody = {
        'profession': newProfession,
        'interests': newInterests,
        'language': newLanguages, // Send languages
        'birthDate': newDob, // Send DOB (assuming API expects 'birthDate')
      };

      final response = await _apiService.updateUserProfile(updateBody);

      final msg = response['message'] ?? response['error'] ?? '';

      if (response['statusCode'] == 200 && response['success'] == true) {
        print('Mandatory info saved to backend.');
      } else {
        String title = context.translate('error');
        showPopupMessage(context, title, msg);
        setState(() {
          // Revert optimistic update if backend failed critically
          // Re-read from prefs might be complex here, just re-flag
          mandatoryInfoNeeded = true; // Re-flag to show dialog again maybe?
        });
      }

      setState(() {
        showSpinner = false;
      });
      refreshPage(); // Refresh UI (already does initSharedPref)
      // No need to call getInfos again here, refreshPage handles UI update
      // If getInfos logic becomes more complex, might revisit this.
    } catch (e) {
      print('Error in _saveMandatoryInfo: $e');
      String title = context.translate('error');
      showPopupMessage(context, title, context.translate('error_saving_info'));
      setState(() {
        mandatoryInfoNeeded = true; // Re-flag if save failed
        showSpinner = false;
      });
    }
  }

  Future<dynamic> getProductOnline(String sellerId, String prdtId) async {
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url =
          Uri.parse('$getProduct?seller=$sellerId&id=$prdtId&email=$email');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        final userAndPrdt = jsonResponse['userPrdt'];

        if (mounted) setState(() {});

        return userAndPrdt;
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

  int notifCount = 0;
  int selected = 0;

  // Map<String, List<String>> operatorsAndCurrencies = {
  //   'BJ': ['MTN_MOMO_BEN', 'MOOV_BEN'],
  //   'CM': ['MTN_MOMO_CMR', 'ORANGE_CMR'],
  //   'BF': ['MOOV_BFA', 'ORANGE_BFA'], // Burkina Faso
  //   'CD': ['VODACOM_MPESA_COD', 'AIRTEL_COD', 'ORANGE_COD'], // DRC
  //   'KE': ['MPESA_KEN'], // Kenya
  //   'NG': ['MTN_MOMO_NGA', 'AIRTEL_NGA'], // Nigeria
  //   'SN': ['FREE_SEN', 'ORANGE_SEN'], // Senegal
  //   'CG': ['AIRTEL_COG', 'MTN_MOMO_COG'], // Republic of the Congo
  //   'GA': ['AIRTEL_GAB'], // Gabon
  //   'CI': ['MTN_MOMO_CIV', 'ORANGE_CIV'], // Côte d'Ivoire
  // };

  void updateCorrespondents(String countryCode) {
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

    setState(() {
      correspondents =
          correspondentMap[countryCode] ?? ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'];
      // *** Ensure momoCor update is safe ***
      if (!correspondents.contains(momoCor)) {
        momoCor = correspondents.isNotEmpty ? correspondents.first : null;
      }
      // If momoCor was already null, it remains null unless a default is set.
      // If the list is empty, momoCor becomes null.
      // If it was valid and still in the new list, it remains unchanged.
    });
  }

  void _showPhoneNumberDialog() {
    // --- Initialize dialog state variables BEFORE showing the dialog ---
    String dialogMomo = '';
    String dialogCountryCode = '+237';
    String dialogMomoCor = '';
    List<String> dialogCorrespondents = ['MTN_MOMO_CMR', 'ORANGE_CMR'];

    // Use parent state: momoNumber, momoCor
    if (momoNumber != null && momoNumber!.isNotEmpty) {
      final countryInfo = getCountryFromPhoneNumber(momoNumber!);
      if (countryInfo != null) {
        dialogCountryCode = countryInfo.dialCode;
        if (momoNumber!.startsWith(dialogCountryCode)) {
          dialogMomo = momoNumber!.substring(dialogCountryCode.length);
        } else {
          dialogMomo = momoNumber!;
        }
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
        dialogCorrespondents = correspondentMap[countryInfo.code] ??
            ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'];
      } else {
        print("Warning: Could not determine country code for $momoNumber");
      }
    }

    if (momoCor != null && dialogCorrespondents.contains(momoCor!)) {
      dialogMomoCor = momoCor!;
    } else if (dialogCorrespondents.isNotEmpty) {
      dialogMomoCor = dialogCorrespondents.first;
    }

    // --- Show the dialog ---
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              context.translate('enter_mobile_money'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning message Container
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.orange.shade300, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange.shade700),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                context.translate('warning'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          context.translate('withdrawal_warning'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          context.translate('withdrawal_warning_message'),
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Phone number field
                  Text(
                    context.translate('phone_number'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff6d7d8b),
                    ),
                  ),
                  SizedBox(height: 8),
                  CustomTextField(
                    margin: 5,
                    hintText: context.translate('mobile_number_example'),
                    value: dialogMomo,
                    initialCountryCode: dialogCountryCode.startsWith('+')
                        ? dialogCountryCode.substring(1)
                        : dialogCountryCode,
                    onChange: (val) {
                      dialogMomo = val;
                    },
                    getCountryDialCode: (code) {
                      setDialogState(() {
                        dialogCountryCode = code;
                      });
                    },
                    getCountryCode: (code) {
                      final correspondentMap = {
                        'BJ': ['MTN_MOMO_BEN', 'MOOV_MOMO_BEN'],
                        'CM': ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'],
                        'BF': ['ORANGE_MOMO_BFA', 'MOOV_MOMO_BFA'],
                        'CD': [
                          'AIRTEL_MOMO_COD',
                          'VODACOM_MOMO_COD',
                          'ORANGE_MOMO_COD'
                        ],
                        'KE': ['SAFARICOM_MOMO_KEN'],
                        'NG': ['MTN_MOMO_NGA', 'AIRTEL_MOMO_NGA'],
                        'SN': [
                          'ORANGE_MOMO_SEN',
                          'FREE_MOMO_SEN',
                          'EXPRESSO_MOMO_SEN'
                        ],
                        'CG': ['MTN_MOMO_COG', 'AIRTEL_MOMO_COG'],
                        'GA': ['AIRTEL_MOMO_GAB', 'MOOV_MOMO_GAB'],
                        'CI': [
                          'MTN_MOMO_CIV',
                          'MOOV_MOMO_CIV',
                          'ORANGE_MOMO_CIV'
                        ],
                      };
                      setDialogState(() {
                        dialogCorrespondents = correspondentMap[code] ??
                            ['MTN_MOMO_CMR', 'ORANGE_MOMO_CMR'];
                        if (!dialogCorrespondents.contains(dialogMomoCor)) {
                          dialogMomoCor = dialogCorrespondents.isNotEmpty
                              ? dialogCorrespondents.first
                              : '';
                        }
                      });
                    },
                    fieldType: CustomFieldType.phone,
                  ),
                  SizedBox(height: 16),

                  // MOMO operator dropdown
                  Text(
                    context.translate('momo_correspondent'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff6d7d8b),
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: dialogMomoCor,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          dialogMomoCor = newValue;
                        });
                      }
                    },
                    items: dialogCorrespondents
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    disabledHint: Text("Select country first"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(context.translate('cancel')),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(context.translate('warning')),
                        content: Text(
                          context.translate('without_momo_warning'),
                        ),
                        actions: [
                          TextButton(
                            child: Text(context.translate('no')),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          TextButton(
                            child: Text(context.translate('yes')),
                            onPressed: () {
                              context.pop();
                              context.pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.translate('confirm')),
                onPressed: () async {
                  if (dialogMomo.isEmpty || dialogMomoCor.isEmpty) {
                    showPopupMessage(context, context.translate('error'),
                        context.translate('fill_all_fields'));
                    return;
                  }
                  final String fullPhoneNumberToSave =
                      dialogCountryCode + dialogMomo;

                  context.pop();
                  await addMOMO(fullPhoneNumberToSave, dialogMomoCor);
                },
              ),
            ],
          );
        });
      },
    );
  }

  // --- Modified addMOMO signature to accept values ---
  Future<void> addMOMO(String fullPhoneNumber, String correspondent) async {
    String msg = '';
    setState(() {
      showSpinner = true;
    });
    try {
      // Prepare the update body for updateUserProfile
      final updateBody = {
        'momoNumber': fullPhoneNumber, // Field name expected by PUT /users/me
        'momoOperator': correspondent, // Field name expected by PUT /users/me
      };

      // ***** CORRECTED: Using updateUserProfile *****
      final response = await _apiService.updateUserProfile(updateBody);
      // ********************************************

      msg = response['message'] ?? response['error'] ?? 'Unknown error';

      final title = (response['statusCode'] != null &&
              response['statusCode'] >= 200 &&
              response['statusCode'] < 300)
          ? context.translate('success')
          : context.translate('error');

      // Update SharedPreferences with the SAVED values
      await prefs.setString('momo', fullPhoneNumber);
      await prefs.setString('momoCorrespondent', correspondent);

      // Update the parent state variables AFTER successful save
      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        setState(() {
          momoNumber = fullPhoneNumber; // Update parent state
          momoCor = correspondent; // Update parent state

          final countryInfo = getCountryFromPhoneNumber(fullPhoneNumber);
          if (countryInfo != null) {
            updateCorrespondents(
                countryInfo.code); // Update parent's correspondent list
          }
        });
      }

      showPopupMessage(context, title, msg);
      print(msg);
    } catch (e) {
      print(e);
      String title = context.translate('error');
      showPopupMessage(context, title, context.translate('error_occurred'));
    }
    setState(() {
      showSpinner = false;
    });
  }

  // --- NEW Function to Fetch App Settings --- (Called from getInfos)
  Future<void> _fetchAndSaveAppSettings() async {
    try {
      final settingsResponse = await _apiService.getAppSettings();

      if (settingsResponse['success'] == true &&
          settingsResponse['data'] != null) {
        final settingsData = settingsResponse['data'] as Map<String, dynamic>;

        final fetchedTelegramUrl = settingsData['telegramGroupUrl'] as String?;
        final fetchedWhatsappUrl = settingsData['whatsappGroupUrl'] as String?;
        final termsId =
            settingsData['termsAndConditionsPdf']?['fileId'] as String?;
        final presentationId =
            settingsData['presentationPdf']?['fileId'] as String?;
        final videoId = settingsData['presentationVideo']?['fileId'] as String?;
        final logoId = settingsData['companyLogo']?['fileId'] as String?;

        String? fetchedLogoUrl;
        if (logoId != null) {
          fetchedLogoUrl = '$settingsFileBaseUrl$logoId';
        }

        await prefs.setString(
            'appSettings_telegramUrl', fetchedTelegramUrl ?? '');
        await prefs.setString(
            'appSettings_whatsappUrl', fetchedWhatsappUrl ?? '');
        await prefs.setString('appSettings_termsPdfId', termsId ?? '');
        await prefs.setString(
            'appSettings_presentationPdfId', presentationId ?? '');
        await prefs.setString('appSettings_presentationVideoId', videoId ?? '');
        await prefs.setString('appSettings_logoUrl', fetchedLogoUrl ?? '');

        if (mounted) {
          setState(() {
            telegramUrl = fetchedTelegramUrl;
            whatsappUrl = fetchedWhatsappUrl;
            termsPdfId = termsId;
            presentationPdfId = presentationId;
            presentationVideoId = videoId;
            appLogoUrl = fetchedLogoUrl;
          });
        }
        print("App settings loaded and saved.");
      } else {
        print(
            "Failed to fetch app settings: ${settingsResponse['message'] ?? settingsResponse['error']}");
      }
    } catch (e) {
      print("Exception fetching app settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffffff),
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: 83 * fem,
          height: 33 * fem,
          child: appLogoUrl != null && appLogoUrl!.isNotEmpty
              ? Image.network(
                  appLogoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/design/images/logo-sbc-final-1-tnu.png',
                    fit: BoxFit.cover,
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
              : Image.asset(
                  'assets/design/images/logo-sbc-final-1-tnu.png',
                  fit: BoxFit.cover,
                ),
        ),
        actions: [
          if (kIsWeb)
            IconButton(
              icon: Icon(Icons.download_rounded),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () {},
            ),
          IconButton(
            icon: Icon(Icons.wallet),
            color: Theme.of(context).colorScheme.onSurface,
            iconSize: 24,
            onPressed: () {
              context.pushNamed(Wallet.id).then((value) {
                if (mounted) {
                  setState(() {
                    initSharedPref();
                  });
                }
              });
            },
          ),
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25 * fem),
                border: Border.all(
                    color: isPartner
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.primary,
                    width: 2.0),
              ),
              child: Container(
                width: 35 * fem,
                height: 35 * fem,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25 * fem),
                  border: Border.all(color: Colors.white),
                  color: Color(0xffc4c4c4),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: profileImage(prefs.getString('avatarId')),
                  ),
                ),
              ),
            ),
            color: Theme.of(context).colorScheme.onSurface,
            iconSize: 24,
            onPressed: () {
              context.pushNamed(Profile.id).then((value) {
                if (mounted) {
                  setState(() {
                    initSharedPref();
                  });
                }
              });
            },
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 3 && isSubscribed
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme:
                  const IconThemeData(size: 22.0, color: Colors.white),
              overlayColor: Theme.of(context).colorScheme.scrim,
              overlayOpacity: 0.4,
              backgroundColor: Theme.of(context).colorScheme.primary,
              children: [
                SpeedDialChild(
                  onTap: () {
                    context.pushNamed(AjouterProduit.id);
                  },
                  child: Icon(Icons.add,
                      color: Theme.of(context).colorScheme.onSurface, size: 30),
                ),
                SpeedDialChild(
                  onTap: () {
                    context.pushNamed(YourProducts.id);
                  },
                  child: Icon(Icons.edit,
                      color: Theme.of(context).colorScheme.onSurface, size: 30),
                ),
              ],
            )
          : null,
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: GNav(
          selectedIndex: _selectedIndex,
          onTabChange: onItemTapped,
          backgroundColor: Colors.white,
          color: Colors.black87,
          activeColor: Colors.white,
          tabBackgroundColor: Theme.of(context).colorScheme.tertiary,
          padding: const EdgeInsets.all(10.0),
          gap: 5,
          tabs: [
            GButton(
              icon: Icons.remove_red_eye_sharp,
              text: context.translate('advertising'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Theme.of(context).colorScheme.onTertiary),
            ),
            GButton(
              icon: Icons.hail_rounded,
              text: context.translate('entertainment'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Theme.of(context).colorScheme.onTertiary),
            ),
            GButton(
              icon: Icons.home,
              text: context.translate('home'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Theme.of(context).colorScheme.onTertiary),
            ),
            GButton(
              icon: Icons.shopping_cart,
              text: context.translate('marketplace'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Theme.of(context).colorScheme.onTertiary),
            ),
            GButton(
              icon: Icons.monetization_on,
              text: context.translate('investment'),
              textStyle: SafeGoogleFont('Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1 * fem,
                  color: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
