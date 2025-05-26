import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Conditional import for dart:html
import 'html_utils.dart' if (dart.library.html) 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:snipper_frontend/api_service.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height / 2 + 30);

    var firstControlPoint = new Offset(size.width / 5, size.height);
    var firstPoint = new Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);
    var secondControlPoint =
        new Offset(size.width - (size.width / 5), size.height);
    var secondPoint = new Offset(size.width, size.height / 2 + 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

var bgGradient = new LinearGradient(
  colors: [const Color(0xFF9BFBC1), const Color(0xFFF3F9A7)],
  tileMode: TileMode.clamp,
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.0, 1.0],
);

var btnGradient = new LinearGradient(
  colors: [const Color(0xFF37ecba), const Color(0xFF72afd3)],
  tileMode: TileMode.clamp,
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  stops: [0.0, 1.0],
);

final gold = Color(0xffFFD700);
final silver = Color(0xff8B9094);

void showPopupMessage(BuildContext context, String title, String msg,
    {Function? callback}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              if (callback != null) {
                callback();
              }
            },
            child: Text('Ok'),
          ),
        ],
      );
    },
  );
}

/// Shows a popup message only once per device
/// Returns true if the popup was shown, false if it was already shown before
Future<bool> showOneTimePopup(
    BuildContext context, String title, String message, String popupKey) async {
  final prefs = await SharedPreferences.getInstance();
  final wasShown = prefs.getBool(popupKey) ?? false;

  if (!wasShown) {
    // Mark as shown for future app launches
    await prefs.setBool(popupKey, true);

    // Show the popup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );

    return true;
  }

  return false;
}

void showSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2), // Customize the duration
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));

  // Optional: Show a Snackbar or some feedback to the user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Copied to clipboard!'),
      duration: Duration(seconds: 2),
    ),
  );
}

TextStyle SafeGoogleFont(
  String fontFamily, {
  TextStyle? textStyle,
  Color? color,
  Color? backgroundColor,
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? wordSpacing,
  TextBaseline? textBaseline,
  double? height,
  Locale? locale,
  Paint? foreground,
  Paint? background,
  List<Shadow>? shadows,
  List<FontFeature>? fontFeatures,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
  double? decorationThickness,
}) {
  try {
    return GoogleFonts.getFont(
      fontFamily,
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  } catch (ex) {
    return GoogleFonts.getFont(
      "Source Sans Pro",
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }
}

Future<String> saveFileLocally(
    String folder, String fileName, String path) async {
  String filePath = '';

  if (kIsWeb) {
    // Set web-specific directory
    filePath = 'assets/$folder/$fileName';
    print('This should never happen');
    return filePath;
  } else {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    filePath = '${appDocumentsDirectory.path}/$folder/$fileName';
    final imageDirectory = Directory('${appDocumentsDirectory.path}/$folder');
    if (!imageDirectory.existsSync()) {
      imageDirectory.createSync(recursive: true);
    }
  }

  final fileBytes = await readFileBytes(path);

  if (ppExist(filePath)) {
    await deleteFile(filePath);
  }
  await saveBytesToMobile(filePath, fileBytes);

  print('File saved to: $filePath');

  return filePath;
}

Future<String> saveFileBytesLocally(
    String folder, String fileName, List<int> fileBytes) async {
  String filePath = '';

  if (kIsWeb) {
    // Set web-specific directory
    filePath = 'assets/$folder/$fileName';

    print('This should never happen');
    await (filePath);
  } else {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    filePath = '${appDocumentsDirectory.path}/$folder/$fileName';

    await saveBytesToMobile(filePath, fileBytes);
  }

  print('File saved to: $filePath');

  return filePath;
}

String saveBytesToMobile(String filePath, List<int> fileBytes) {
  // Split the file path using the '/' delimiter
  List<String> pathSegments = filePath.split('/');

  // Remove the last element (file name) from the list
  pathSegments.removeLast();

  // Join the remaining segments to obtain the directory path
  String directoryPath = pathSegments.join('/');

  // Create a directory to this file
  final imageDirectory = Directory(directoryPath);
  if (!imageDirectory.existsSync()) {
    imageDirectory.createSync(recursive: true);
  }

  File file = File(filePath);

  file.writeAsBytesSync(fileBytes);

  return filePath;
}

Future<String> mobilePathGetter(String simplePath) async {
  if (kIsWeb) {
    // Set web-specific directory
    return 'assets/$simplePath';
  } else {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return '${appDocumentsDirectory.path}/$simplePath';
  }
}

Future<List<int>> readFileBytesMobile(String filePath) async {
  try {
    File file = File(filePath);

    if (await file.exists()) {
      List<int> bytes = await file.readAsBytes();
      return bytes;
    } else {
      throw FileSystemException('File not found', filePath);
    }
  } catch (error) {
    print('Error reading file: $error');
    return [];
  }
}

Future<List<int>> readFileBytes(String filePath) async {
  try {
    return readFileBytesMobile(filePath);
  } catch (error) {
    print('Error reading file: $error');
    return [];
  }
}

bool ppExist(String path) {
  return path.isNotEmpty;
}

ImageProvider<Object> profileImage(String? avatarId) {
  const String defaultAvatarPlaceholder = // Placeholder or default image URL
      'https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg'; // Replace with your actual default

  if (avatarId != null && avatarId.isNotEmpty) {
    // Construct the full URL using the base URL and the avatarId
    final String fullAvatarUrl = '$settingsFileBaseUrl$avatarId';
    // print('Loading avatar: $fullAvatarUrl'); // Optional: for debugging
    return NetworkImage(fullAvatarUrl);
  } else {
    // Return a default image if avatarId is null or empty
    // print('Loading default avatar'); // Optional: for debugging
    // You can use a NetworkImage for a remote default or AssetImage for local
    return NetworkImage(defaultAvatarPlaceholder);
    // Example using local asset:
    // return const AssetImage('assets/design/images/default_avatar.png');
  }
}

Future<void> deleteFile(String filePath) async {
  try {
    if (kIsWeb) {
      print('is on web');
    } else {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('File deleted successfully');
      } else {
        print('File does not exist');
      }
    }
  } catch (e) {
    print('Error deleting file: $e');
  }
}

void launchURL(String url) {
  final uri = Uri.parse(url);
  launchUrl(uri);
  // if (canLaunchUrl(uri)) {
  // } else {
  //   throw 'Could not launch $url';
  // }
}

void sendWhatsAppMessage(BuildContext context, String name, String phoneNumber,
    {String? messageBody}) async {
  final translator = AppLocalizations.of(context);
  String messageToSend;

  if (messageBody != null && messageBody.isNotEmpty) {
    // Use the provided message if it exists
    messageToSend = messageBody;
  } else {
    // Construct the default message if no messageBody is provided
    messageToSend = [
      translator.translate('greeting', {'name': name}),
      translator.translate('assistance'),
      translator.translate('good_news'),
      translator.translate('price_msg'),
      translator.translate('benefits'),
      translator.translate('contacts_msg'),
      translator.translate('courses'),
      translator.translate('affiliation_msg'),
      translator.translate('join_us'),
      translator.translate('link'),
    ].join("\n\n");
  }

  String encodedMessage = Uri.encodeComponent(messageToSend);
  String whatsappUrl = "https://wa.me/$phoneNumber?text=$encodedMessage";

  final uri = Uri.parse(whatsappUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // Fallback or error handling
    print('Could not launch $whatsappUrl');
    showPopupMessage(context, 'Error',
        'Could not open WhatsApp.'); // Show user-friendly error
  }
}

Country? getCountryFromPhoneNumber(String phoneNumber) {
  for (Country country in countries) {
    if (phoneNumber.startsWith(country.dialCode)) {
      return country;
    }
  }
  return null;
}

String generateUniqueFileName(String prefix, String extension) {
  // Generate a timestamp (milliseconds since epoch)
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  // Generate a random component (you can use any random logic you prefer)
  String randomComponent = (1000 + Random().nextInt(9000)).toString();

  // Combine the prefix, timestamp, random component, and extension to create a unique name
  String uniqueFileName = '$prefix-$timestamp-$randomComponent.$extension';

  return uniqueFileName;
}

/// Formats an ISO date string into a specified pattern.
/// Defaults to 'dd/MM/yyyy'.
String formatDateString(String isoDateString, {String pattern = 'dd/MM/yyyy'}) {
  try {
    final DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat(pattern).format(dateTime);
  } catch (e) {
    print('Error formatting date string: $isoDateString - $e');
    return isoDateString; // Return original or a default error string
  }
}

Future<void> saveNotification(Map<String, String> newNotification) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final oldNotifications = await getNotifications();

  oldNotifications.add(newNotification);

  // Convert the list to a JSON string
  String jsonList = jsonEncode(oldNotifications);

  // Save the JSON string to shared preferences
  prefs.setString('notifications', jsonList);

  final x = prefs.getString('notifications');
  print(x);
}

Future<void> deleteNotifications() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Save the JSON string to shared preferences
  prefs.setString('notifications', '');
}

Future<List<Map<String, String>>> getNotifications() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the JSON string from shared preferences
  String? jsonList = prefs.getString('notifications');

  // If the JSON string is not null, decode it back to a list
  if (jsonList != null && jsonList.isNotEmpty) {
    List<dynamic> decodedList = jsonDecode(jsonList);

    // Convert the dynamic list to a list of maps with correct types
    List<Map<String, String>> myList =
        decodedList.map((item) => Map<String, String>.from(item)).toList();

    return myList;
  } else {
    // If the JSON string is null, return an empty list
    return [];
  }
}

// Future<void> saveTransactionList(List<dynamic> transactions) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();

//   // Convert the list to a JSON string
//   String jsonList = jsonEncode(transactions);

//   // Save the JSON string to shared preferences
//   prefs.setString('transaction', jsonList);
// }

// Future<void> savePartnerTransList(List<dynamic> transactions) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();

//   // Convert the list to a JSON string
//   String jsonList = jsonEncode(transactions);

//   // Save the JSON string to shared preferences
//   prefs.setString('partnerTrans', jsonList);
// }

Future<void> deleteAllKindTransactions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Save the JSON string to shared preferences
  prefs.setString('transaction', '');
  prefs.setString('partnerTrans', '');
}

// Future<List<Map<String, dynamic>>> getPartnerTrans() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();

//   // Retrieve the JSON string from shared preferences
//   String? jsonList = prefs.getString('partnerTrans');

//   print(jsonList);

//   // If the JSON string is not null, decode it back to a list
//   if (jsonList != null && jsonList.isNotEmpty) {
//     List<Map<String, dynamic>> userTransactions = jsonDecode(jsonList)
//         .map((item) {
//           // Assuming 'date' is the key for the date field
//           if (item['date'] != null) {
//             DateTime date = DateTime.parse(item['date']);
//             // Add the DateTime object to the map
//             item['date'] = date;
//           }
//           return item;
//         })
//         .cast<Map<String, dynamic>>()
//         .toList();

//     return userTransactions.reversed.take(20).toList();
//   } else {
//     // If the JSON string is null, return an empty list
//     return [];
//   }
// }

/// Format the time as HH:MM AM/PM
String formatTime(DateTime dateTime) {
  String formattedTime =
      "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ";

  // Determine whether it's AM or PM
  formattedTime += (dateTime.hour < 12) ? 'AM' : 'PM';

  return formattedTime;
}

Future<bool> requestContactPermission() async {
  if (await Permission.contacts.isGranted) {
    print('Contact permission already granted');
    return true;
  }

  var status = await Permission.contacts.request();
  if (status.isGranted) {
    // Permission granted, you can now proceed to read contacts
    print('Contact permission granted');
    return true;
  } else {
    // Permission denied
    print('Contact permission denied');
    return false;
  }
}

String formatAmount(int amount) {
  if (amount >= 1000000000) {
    return '${(amount / 1000000000).toStringAsFixed(1)}B';
  } else if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  } else {
    return amount.toString();
  }
}

// Function to capitalize the first letter of each word
String capitalizeWords(String? input) {
  if (input == null) return '';

  return input.split(' ').map((word) {
    if (word.isNotEmpty) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }
    return '';
  }).join(' ');
}

Future<dynamic> getProductOnline(
  String sellerEmail,
  String prdtId,
  BuildContext context,
) async {
  // Instantiate ApiService
  final apiService = ApiService();

  try {
    // Call the ApiService method
    final response = await apiService.getProductDetails(prdtId);

    String msg = response.message;
    int? statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300 && response.apiReportedSuccess) {
      // Return the product data, usually found in response.body['data']
      return response.body['data'];
    } else {
      // Handle error response
      String error = response.message;
      if (error == 'Accès refusé') {
        // Example specific error handling
        String title = "Erreur. Accès refusé.";
        showPopupMessage(context, title, msg);
      } else {
        String title = 'Erreur';
        showPopupMessage(context, title, msg.isNotEmpty ? msg : error);
      }
      print('API Error getProductOnline: $statusCode - $error - $msg');
      return null; // Indicate failure
    }
  } catch (e) {
    print('Exception in getProductOnline: $e');
    String title = 'Erreur';
    String msg =
        'Une erreur s\'est produite: ${e.toString()}'; // More generic error message
    showPopupMessage(context, title, msg);
    return null; // Indicate failure
  }
}

class ScreenArguments {
  final String prdtId;
  final String sellerEmail;

  ScreenArguments(this.prdtId, this.sellerEmail);
}

// Add this function for email validation
bool isValidEmailDomain(String email) {
  // Regular expression to match common email domains
  final RegExp emailRegex = RegExp(
    r'@(gmail|outlook|hotmail|yahoo|icloud|aol|protonmail|zoho|mail|gmx|yandex|fastmail|tutanota|me|mac|live|msn)\.(com|net|org|ru|de|uk|fr|ca|au|in|it|es|br)$',
    caseSensitive: false,
  );

  return emailRegex.hasMatch(email);
}

// --- Web Download Helper ---
void downloadFileWeb(String content, String filename) {
  if (kIsWeb) {
    // Create blob from the content
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);

    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click(); // Trigger the download

    // Revoke the object URL to free up resources
    html.Url.revokeObjectUrl(url);
  } else {
    print("downloadFileWeb is only intended for web use.");
    // Optionally, you could try to save it locally on mobile here too,
    // but the VCF export in contact-update handles mobile differently for now.
  }
}

// --- End Web Download Helper ---
