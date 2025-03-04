import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;
import 'package:contacts_service/contacts_service.dart';

class ContactUpdate extends StatefulWidget {
  static const id = 'contact-update';

  @override
  State<ContactUpdate> createState() => _ContactUpdateState();
}

class _ContactUpdateState extends State<ContactUpdate> {
  DateTime? startDate;
  DateTime? endDate;
  bool showSpinner = false;
  String? email;
  String? token;
  String downloadUpdateUrl = '';
  int contactsLength = 0;
  int percSaved = 0;

  @override
  void initState() {
    super.initState();
    initPrefs();
    endDate = DateTime.now();
    startDate = DateTime.now().subtract(const Duration(days: 7));
  }

  Future<void> initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    token = prefs.getString('token');
    setState(() {});
  }

  Future<String?> downloadVCF(BuildContext context) async {
    try {
      if (kIsWeb) {
        String msg = context.translate('feature_not_available_web');
        String title = context.translate('error');
        showPopupMessage(context, title, msg);
        return null;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse(downloadUpdateUrl);

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      final imageData = jsonResponse['vcfData'];
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        final imageBytes = base64Decode(imageData);
        if (kIsWeb) {
          return null;
        }
        String fileName = 'contacts.vcf';
        String folder = 'VCF Files';

        final permanentPath =
            await saveFileBytesLocally(folder, fileName, imageBytes);

        return permanentPath;
      } else {
        String title = context.translate('error');
        showPopupMessage(context, title, msg);
        print('VCF request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
    return null;
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
      // For web, use a more web-friendly approach
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? startDate ?? now : endDate ?? now,
        firstDate: DateTime(2020),
        lastDate: now,
        initialEntryMode:
            DatePickerEntryMode.calendarOnly, // Force calendar mode on web
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
      // For mobile, use the default implementation
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

  Future<String> createContactsOTP(BuildContext context) async {
    final url = Uri.parse('$createContactsOTPLink?email=$email');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final response = await http.post(url, headers: headers);
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['otp'].toString();
  }

  void updateContacts() async {
    if (startDate == null || endDate == null) {
      showPopupMessage(
        context,
        context.translate('error'),
        context.translate('select_both_dates'),
      );
      return;
    }

    setState(() {
      showSpinner = true;
    });

    final otp = await createContactsOTP(context);

    if (endDate!.isBefore(startDate!)) {
      showPopupMessage(
        context,
        context.translate('error'),
        context.translate('end_date_before_start'),
      );
      return;
    }

    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate!);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate!);

    downloadUpdateUrl =
        '$downloadContactsUpdates?email=$email&startDate=$formattedStartDate&endDate=$formattedEndDate&otp=$otp';

    if (kIsWeb) {
      launchURL(downloadUpdateUrl);
      setState(() {
        showSpinner = false;
      });
      return;
    }

    try {
      final path = await downloadVCF(context);
      if (path == null) {
        showPopupMessage(
          context,
          context.translate('error'),
          context.translate('error_occurred'),
        );
        return;
      }

      final contacts = await readVcfFile(path);
      await saveContacts(contacts);
    } catch (e) {
      print(e);
      showPopupMessage(
        context,
        context.translate('error'),
        context.translate('error_occurred'),
      );
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      title: context.translate('select_date_range'),
      inAsyncCall: showSpinner,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                context.translate('select_date_range'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    context.translate('start_date'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(formatDate(startDate)),
                  trailing: Icon(Icons.calendar_today, color: orange),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    context.translate('end_date'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(formatDate(endDate)),
                  trailing: Icon(Icons.calendar_today, color: orange),
                  onTap: () => _selectDate(context, false),
                ),
              ),
              const SizedBox(height: 40),
              ReusableButton(
                title: context.translate('update_contacts'),
                onPress: updateContacts,
                lite: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
