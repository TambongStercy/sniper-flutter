import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:snipper_frontend/design/accueil.dart'
    show allProfessions, allInterests, allLanguages;
import 'package:snipper_frontend/constants/countries.dart';

// Define lists for filter dropdowns (reuse from accueil.dart or define here)
final List<String> filterSexOptions = ['Male', 'Female', 'Other'];

class ContactUpdate extends StatefulWidget {
  static const id = 'contact-update';

  @override
  State<ContactUpdate> createState() => _ContactUpdateState();
}

class _ContactUpdateState extends State<ContactUpdate>
    with TickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  bool showSpinner = false;
  String? email;
  int contactsLength = 0;
  int percSaved = 0;

  bool isCibleSubscribed = false;
  bool isSubscribed = false;

  // --- Filter State Variables ---
  String? selectedCountry;
  String? selectedSex;
  RangeValues? selectedAgeRange;
  bool _isAgeFilterEnabled = false;
  String? selectedLanguage;
  String? selectedProfession;
  List<String> selectedInterests = [];
  // --- End Filter State ---

  // --- Contact List State ---
  List<Map<String, dynamic>> filteredContacts = [];
  bool isLoadingContacts = false;
  int currentPage = 1;
  bool hasMoreContacts = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // --- End Contact List State ---

  late TabController _tabController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initPrefs();
    endDate = DateTime.now();
    startDate = DateTime.now().subtract(const Duration(days: 7));
    selectedAgeRange = RangeValues(18, 80);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !isLoadingContacts &&
          hasMoreContacts) {
        _fetchFilteredContacts(loadMore: true);
      }
    });

    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        _searchQuery = _searchController.text;
        _performSearch();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFilteredContacts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');

    isSubscribed = prefs.getBool('isSubscribed') ?? false;
    List<String> activeSubscriptions =
        prefs.getStringList('activeSubscriptions') ?? [];
    isCibleSubscribed =
        activeSubscriptions.any((sub) => sub.toLowerCase() == 'cible');

    currentPage = 1;
    hasMoreContacts = true;
    filteredContacts = [];
    setState(() {});
  }

  Map<String, dynamic> _getCurrentFilters() {
    final Map<String, dynamic> filters = {};
    if (_searchQuery.isNotEmpty) filters['name'] = _searchQuery;

    if (selectedCountry != null) filters['country'] = selectedCountry;
    if (selectedSex != null) filters['sex'] = selectedSex;
    if (_isAgeFilterEnabled && selectedAgeRange != null) {
      filters['minAge'] = selectedAgeRange!.start.round().toString();
      filters['maxAge'] = selectedAgeRange!.end.round().toString();
    }
    if (selectedLanguage != null) filters['language'] = selectedLanguage;
    if (selectedProfession != null) filters['profession'] = selectedProfession;
    if (selectedInterests.isNotEmpty) filters['interests'] = selectedInterests;
    return filters;
  }

  Future<String?> downloadVCF(BuildContext context) async {
    if (kIsWeb) {
      setState(() {
        showSpinner = true;
      });
      try {
        final filters = _getCurrentFilters();
        final response = await _apiService.exportContacts(filters);
        final statusCode = response['statusCode'];
        final vcfData = response['data'];

        if (statusCode != null &&
            statusCode >= 200 &&
            statusCode < 300 &&
            vcfData is String &&
            vcfData.isNotEmpty) {
          final timestamp =
              DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          downloadFileWeb(vcfData, 'sbc_contacts_$timestamp.vcf');
          showPopupMessage(context, context.translate('success'),
              context.translate('download_started'));
        } else {
          String errorMsg = response['message'] ??
              response['error'] ??
              context.translate('vcf_download_failed');
          if (vcfData == null || (vcfData is String && vcfData.isEmpty)) {
            errorMsg = context.translate('vcf_data_empty');
          }
          showPopupMessage(context, context.translate('error'), errorMsg);
          print(
              'API Error downloadVCF (Web): ${response['statusCode']} - $errorMsg');
        }
      } catch (e) {
        print('Exception in downloadVCF (Web): $e');
        showPopupMessage(context, context.translate('error'),
            context.translate('error_occurred'));
      } finally {
        if (mounted)
          setState(() {
            showSpinner = false;
          });
      }
      return null;
    }

    setState(() {
      showSpinner = true;
    });
    String? permanentPath;
    try {
      final filters = _getCurrentFilters();
      final response = await _apiService.exportContacts(filters);

      final statusCode = response['statusCode'];
      final vcfData = response['data'];

      if (statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300 &&
          vcfData is String &&
          vcfData.isNotEmpty) {
        try {
          final vcfBytes = utf8.encode(vcfData);
          String fileName =
              'sbc_contacts_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.vcf';
          String folder = 'SBC Contacts';
          permanentPath =
              await saveFileBytesLocally(folder, fileName, vcfBytes);
          print("VCF file saved to: $permanentPath");
          showPopupMessage(context, context.translate('success'),
              context.translate('vcf_download_complete') + ': $permanentPath');

          if (permanentPath != null) {
            final contacts = await readVcfFile(permanentPath);
            await saveContacts(contacts);
          }
        } catch (e) {
          print("Error processing/saving VCF data (Mobile): $e");
          showPopupMessage(context, context.translate('error'),
              context.translate('vcf_processing_error'));
          permanentPath = null;
        }
      } else {
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('vcf_download_failed');
        if (vcfData == null || (vcfData is String && vcfData.isEmpty)) {
          errorMsg = context.translate('vcf_data_empty');
        }
        showPopupMessage(context, context.translate('error'), errorMsg);
        print(
            'API Error downloadVCF (Mobile): ${response['statusCode']} - $errorMsg');
      }
    } catch (e) {
      print('Exception in downloadVCF (Mobile): $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
    return permanentPath;
  }

  Future<List<Contact>> readVcfFile(String vcfPath) async {
    File file = File(vcfPath);
    if (await file.exists()) {
      String content = await file.readAsString();
      return parseVcfContent(content);
    } else {
      throw Exception('VCF file not found');
    }
  }

  List<Contact> parseVcfContent(String content) {
    List<Contact> contacts = [];
    List<String> lines = LineSplitter.split(content).toList();
    Contact? contact;

    for (String line in lines) {
      if (line.startsWith('BEGIN:VCARD')) {
        contact = Contact();
        contact.phones = [];
        contact.displayName = '';
        continue;
      }

      if (contact == null) {
        continue;
      }

      if (line.startsWith('FN')) {
        final realName = line.split(':')[1].replaceFirst(' SBC', '');
        contact.displayName = realName;
        contact.suffix = realName;
        contact.familyName = 'SBC';
      }

      if (line.startsWith('TEL')) {
        String phoneNumber = line.split(':')[1];
        contact.phones?.add(Item(label: 'mobile', value: phoneNumber));
      }

      if (line.startsWith('END:VCARD')) {
        contacts.add(contact);
        contact = null;
      }
    }

    return contacts;
  }

  Future<void> saveContacts(List<Contact> importedContacts) async {
    percSaved = 0;
    contactsLength = importedContacts.length;

    showLoaderDialog(context);

    final isGranted = await requestContactPermission();

    if (!isGranted) {
      Navigator.pop(context);
      String msg = context.translate('contacts_permission_denied');
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
      return;
    }

    print('SBC contacts saving....');
    for (Contact contact in importedContacts) {
      percSaved++;
      await ContactsService.addContact(contact);
    }

    Navigator.pop(context);

    String msg = context.translate('contacts_saved_successfully',
        args: {'count': contactsLength.toString()});
    String title = context.translate('congratulations');
    showPopupMessage(context, title, msg);
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(context.translate('saving_contacts')),
      content: Container(
        height: 70,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 0),
              child: Text(context.translate('saving_contacts_message')),
            ),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    if (kIsWeb) {
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? startDate ?? now : endDate ?? now,
        firstDate: DateTime(2020),
        lastDate: now,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          if (isStartDate) {
            startDate = picked;
          } else {
            endDate = picked;
          }
        });
      }
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        setState(() {
          if (isStartDate) {
            startDate = picked;
          } else {
            endDate = picked;
          }
        });
      }
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return context.translate('select_date');
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _exportContactsVCF() async {
    await downloadVCF(context);
  }

  Future<void> _fetchFilteredContacts({bool loadMore = false}) async {
    if (isLoadingContacts) return;
    if (loadMore && !hasMoreContacts) return;

    setState(() {
      isLoadingContacts = true;
      if (!loadMore) {
        filteredContacts = [];
        currentPage = 1;
        hasMoreContacts = true;
      }
    });

    try {
      Map<String, dynamic> filters = _getCurrentFilters();
      filters['page'] = currentPage.toString();
      filters['limit'] = '20';

      print("Fetching contacts with filters: $filters");

      final response = await _apiService.searchContacts(filters);

      print("Raw Contact Search Response: $response");

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        List<dynamic> contactsData = [];
        Map<String, dynamic>? paginationData;
        bool dataExtractionError = false;

        if (response['data'] is List) {
          contactsData = response['data'];
        } else {
          print(
              "Error: Expected 'data' to be a List, but got: ${response['data'].runtimeType}");
          dataExtractionError = true;
        }

        if (response['pagination'] is Map<String, dynamic>) {
          paginationData = response['pagination'] as Map<String, dynamic>?;
        } else if (response['pagination'] != null) {
          print(
              "Error: Expected 'pagination' to be a Map<String, dynamic>, but got: ${response['pagination'].runtimeType}");
        }

        if (dataExtractionError) {
          showPopupMessage(context, context.translate('error'),
              context.translate('contact_response_error'));
          setState(() {
            hasMoreContacts = false;
            isLoadingContacts = false;
          });
          return;
        }

        final newContacts =
            contactsData.map((c) => Map<String, dynamic>.from(c)).toList();

        setState(() {
          filteredContacts.addAll(newContacts);
          currentPage++;
          if (paginationData != null) {
            final int totalItems = paginationData['totalCount'] is int
                ? paginationData['totalCount']
                : 0;
            final int limit =
                paginationData['limit'] is int ? paginationData['limit'] : 20;
            final int totalPages = paginationData['totalPages'] is int
                ? paginationData['totalPages']
                : (totalItems > 0 ? (totalItems / limit).ceil() : 1);
            hasMoreContacts = currentPage <= totalPages;
          } else {
            hasMoreContacts = newContacts.length == 20;
          }
        });
      } else {
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('contact_fetch_failed');
        showPopupMessage(context, context.translate('error'), errorMsg);
        print(
            'API Error _fetchFilteredContacts: ${response['statusCode']} - $errorMsg');
        setState(() {
          hasMoreContacts = false;
        });
      }
    } catch (e, stackTrace) {
      print('Exception in _fetchFilteredContacts: $e');
      print('Stack trace: $stackTrace');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
      setState(() {
        hasMoreContacts = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingContacts = false;
        });
      }
    }
  }

  void _performSearch() {
    _fetchFilteredContacts(loadMore: false);
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.translate('contacts')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: context.translate('search_contacts')),
              Tab(text: context.translate('export_contacts')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSearchContactsTab(context, fem, ffem),
            _buildExportContactsTab(context, fem, ffem),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContactsTab(
      BuildContext context, double fem, double ffem) {
    final bool hasAdvancedSubscription = isCibleSubscribed;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(15.0 * fem),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.translate('search_by_name'),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 10 * fem),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchFilteredContacts(loadMore: false),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              padding:
                  EdgeInsets.fromLTRB(15.0 * fem, 0, 15.0 * fem, 15.0 * fem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterWidgets(
                      context, hasAdvancedSubscription, false, fem, ffem),
                  const SizedBox(height: 20),
                  _buildContactList(context, fem, ffem),
                  if (isLoadingContacts && filteredContacts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!hasMoreContacts && filteredContacts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                          child: Text(context.translate('no_more_contacts'))),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportContactsTab(
      BuildContext context, double fem, double ffem) {
    final bool hasAdvancedSubscription = isCibleSubscribed;
    return SingleChildScrollView(
      padding: EdgeInsets.all(15.0 * fem),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          context.translate('select_date_range'),
          style: TextStyle(fontSize: 16 * ffem, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10 * fem),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5 * fem),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12 * fem),
          ),
          child: ListTile(
            title: Text(context.translate('start_date')),
            subtitle: Text(formatDate(startDate)),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, true),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5 * fem),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12 * fem),
          ),
          child: ListTile(
            title: Text(context.translate('end_date')),
            subtitle: Text(formatDate(endDate)),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, false),
          ),
        ),
        SizedBox(height: 20 * fem),
        Divider(),
        SizedBox(height: 10 * fem),
        Text(
          context.translate('filter_export_optional'),
          style: TextStyle(fontSize: 16 * ffem, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10 * fem),
        _buildFilterWidgets(context, hasAdvancedSubscription, true, fem, ffem),
        SizedBox(height: 20 * fem),
        ReusableButton(
          title: context.translate('download_vcf'),
          onPress: _exportContactsVCF,
          lite: false,
        ),
      ]),
    );
  }

  Widget _buildFilterWidgets(BuildContext context, bool hasAdvancedSubscription,
      bool isExportTab, double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          fem,
          ffem,
          context.translate('country'),
          context.translate('all_countries'),
          selectedCountry,
          africanCountries
              .map((c) => {'value': c.code, 'display': c.name})
              .toList(),
          (newValue) => setState(() => selectedCountry = newValue),
        ),
        if (hasAdvancedSubscription) ...[
          Divider(height: 25 * fem),
          Text(context.translate('advanced_filters'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 16 * ffem)),
          SizedBox(height: 15 * fem),
          _buildDropdownField(
            fem,
            ffem,
            context.translate('sex'),
            context.translate('all_sexes'),
            selectedSex,
            filterSexOptions
                .map((s) =>
                    {'value': s, 'display': context.translate(s.toLowerCase())})
                .toList(),
            (newValue) => setState(() => selectedSex = newValue),
          ),
          _buildRangeSliderWithSwitch(fem, ffem),
          _buildDropdownField(
            fem,
            ffem,
            context.translate('language'),
            context.translate('all_languages'),
            selectedLanguage,
            allLanguages
                .map((l) => {'value': l['code']!, 'display': l['name']!})
                .toList(),
            (newValue) => setState(() => selectedLanguage = newValue),
          ),
          _buildDropdownField(
            fem,
            ffem,
            context.translate('profession'),
            context.translate('all_professions'),
            selectedProfession,
            allProfessions.map((p) => {'value': p, 'display': p}).toList(),
            (newValue) => setState(() => selectedProfession = newValue),
          ),
          _buildMultiSelectModalButton(
            fem,
            ffem,
            context.translate('interests'),
            allInterests,
            selectedInterests,
            (selected) => setState(() => selectedInterests = selected),
          ),
        ] else if (!isExportTab) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15 * fem),
            child: Text(context.translate('not_cible_subscriber')),
          )
        ]
      ],
    );
  }

  Widget _buildContactList(BuildContext context, double fem, double ffem) {
    if (isLoadingContacts && filteredContacts.isEmpty) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(20.0 * fem),
              child: CircularProgressIndicator()));
    }
    if (filteredContacts.isEmpty && !isLoadingContacts) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(20.0 * fem),
              child: Text(context.translate('no_contacts_found'))));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        final name = contact['name'] as String? ?? 'N/A';
        final dynamic phoneValue = contact['phoneNumber'];
        final String phoneNumber = phoneValue is String ? phoneValue : '';

        final avatarId = contact['avatarId'] as String?;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profileImage(avatarId),
            radius: 25 * fem,
            child: avatarId == null || avatarId.isEmpty
                ? Icon(Icons.person, color: Colors.grey.shade400)
                : null,
            backgroundColor: Colors.grey.shade200,
          ),
          title: Text(name, style: TextStyle(fontSize: 14 * ffem)),
          subtitle: Text(phoneNumber, style: TextStyle(fontSize: 12 * ffem)),
          onTap: () {
            if (phoneNumber.isNotEmpty) {
              String cleanedPhone =
                  phoneNumber.replaceAll(RegExp(r'[\s+()-]'), '');
              if (!cleanedPhone.startsWith('+') && cleanedPhone.length > 9) {}
              final whatsappUrl = 'https://wa.me/$cleanedPhone';
              print('Opening WhatsApp: $whatsappUrl');
              launchURL(whatsappUrl);
            } else {
              showPopupMessage(context, context.translate('error'),
                  context.translate('phone_number_missing'));
            }
          },
          trailing: Icon(Icons.message),
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Container _label(double fem, double ffem, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 7 * fem),
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

  Widget _buildDropdownField(
    double fem,
    double ffem,
    String label,
    String hint,
    String? currentValue,
    List<Map<String, String>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(fem, ffem, label),
        DropdownButtonFormField<String?>(
          value: currentValue,
          hint: Text(hint),
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(hint),
            ),
            ...items.map<DropdownMenuItem<String?>>((Map<String, String> item) {
              return DropdownMenuItem<String?>(
                value: item['value'],
                child: Text(item['display']!),
              );
            }).toList(),
          ],
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
            _showMultiSelectDialog(
                context: context,
                title: label,
                allOptions: allOptions,
                initiallySelectedOptions: selectedOptions,
                onSave: onSave,
                fem: fem,
                ffem: ffem);
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
                Expanded(
                  child: Text(
                    selectedOptions.isEmpty
                        ? context.translate('tap_to_select')
                        : context.translate('selected_count',
                            args: {'count': selectedOptions.length.toString()}),
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 14 * ffem,
                      color: selectedOptions.isEmpty
                          ? Colors.grey[600]
                          : Color(0xff25313c),
                    ),
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildRangeSliderWithSwitch(double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label(fem, ffem, context.translate('age_range')),
            Switch(
              value: _isAgeFilterEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isAgeFilterEnabled = value;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        AbsorbPointer(
          absorbing: !_isAgeFilterEnabled,
          child: Opacity(
            opacity: _isAgeFilterEnabled ? 1.0 : 0.5,
            child: RangeSlider(
              values: selectedAgeRange ?? RangeValues(18, 80),
              min: 0,
              max: 100,
              divisions: 100,
              labels: RangeLabels(
                selectedAgeRange?.start.round().toString() ?? '18',
                selectedAgeRange?.end.round().toString() ?? '80',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  selectedAgeRange = values;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Colors.grey[300],
            ),
          ),
        ),
        Center(
          child: Text(
            '${selectedAgeRange?.start.round() ?? 18} - ${selectedAgeRange?.end.round() ?? 80} ${context.translate("years")}',
            style: TextStyle(fontSize: 12 * ffem, color: Colors.grey[600]),
          ),
        ),
        SizedBox(height: 15 * fem),
      ],
    );
  }

  Future<void> _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<String> allOptions,
    required List<String> initiallySelectedOptions,
    required Function(List<String>) onSave,
    required double fem,
    required double ffem,
  }) async {
    final TextEditingController searchController = TextEditingController();
    List<String> tempSelectedOptions = List.from(initiallySelectedOptions);
    List<String> filteredOptions = List.from(allOptions);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void filterSearchResults(String query) {
              if (query.isEmpty) {
                filteredOptions = List.from(allOptions);
              } else {
                filteredOptions = allOptions
                    .where((item) =>
                        item.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              }
              setDialogState(() {});
            }

            return AlertDialog(
              title: Text(title),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: context.translate('search'),
                        hintText: context.translate('search'),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8 * fem)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10 * fem),
                      ),
                      onChanged: filterSearchResults,
                    ),
                    SizedBox(height: 10 * fem),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredOptions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = filteredOptions[index];
                          final bool isSelected =
                              tempSelectedOptions.contains(option);
                          return CheckboxListTile(
                            title: Text(option,
                                style: TextStyle(fontSize: 14 * ffem)),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelectedOptions.add(option);
                                } else {
                                  tempSelectedOptions.remove(option);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        },
                      ),
                    ),
                  ],
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
                  child: Text(context.translate('save')),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    onSave(tempSelectedOptions);
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
}
