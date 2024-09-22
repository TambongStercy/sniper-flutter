import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
final orange = Color(0xffED8B00);

void showPopupMessage(BuildContext context, String title, String msg) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          ),
        ],
      );
    },
  );
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

ImageProvider<Object> profileImage(String avatarPath) {
  // if (kIsWeb) {
  //   print('avatarPath please call setState: $avatarPath');

  // }
  const nothingPP =
      'https://www.shutterstock.com/image-vector/default-avatar-profile-icon-social-600nw-1677509740.jpg';
  return NetworkImage(
      ((avatarPath == '') ? nothingPP : avatarPath));

  // if (ppExist(avatarPath)) {
  //   print('avatarPath please call setState: $avatarPath');

  //   // Check if the user's profile picture path is not empty and the file exists.

  //   return FileImage(File(avatarPath));
  // }
  // // Return the default profile picture from the asset folder.
  // return const AssetImage(
  //   'assets/design/images/your picture.png',
  // );
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

Future<void> saveTransactionList(List<dynamic> transactions) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert the list to a JSON string
  String jsonList = jsonEncode(transactions);

  // Save the JSON string to shared preferences
  prefs.setString('transaction', jsonList);
}

Future<void> savePartnerTransList(List<dynamic> transactions) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert the list to a JSON string
  String jsonList = jsonEncode(transactions);

  // Save the JSON string to shared preferences
  prefs.setString('partnerTrans', jsonList);
}

Future<void> deleteAllKindTransactions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Save the JSON string to shared preferences
  prefs.setString('transaction', '');
  prefs.setString('partnerTrans', '');
}

Future<List<Map<String, dynamic>>> getTransactions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the JSON string from shared preferences
  String? jsonList = prefs.getString('transaction');

  // If the JSON string is not null, decode it back to a list
  if (jsonList != null && jsonList.isNotEmpty) {
    List<Map<String, dynamic>> userTransactions = jsonDecode(jsonList)
        .map((item) {
          // Assuming 'date' is the key for the date field
          if (item['date'] != null) {
            DateTime date = DateTime.parse(item['date']);
            // Add the DateTime object to the map
            item['date'] = date;
          }
          return item;
        })
        .cast<Map<String, dynamic>>()
        .toList();

    return userTransactions.reversed.take(20).toList();
  } else {
    // If the JSON string is null, return an empty list
    return [];
  }
}

Future<List<Map<String, dynamic>>> getPartnerTrans() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the JSON string from shared preferences
  String? jsonList = prefs.getString('partnerTrans');

  print(jsonList);

  // If the JSON string is not null, decode it back to a list
  if (jsonList != null && jsonList.isNotEmpty) {
    List<Map<String, dynamic>> userTransactions = jsonDecode(jsonList)
        .map((item) {
          // Assuming 'date' is the key for the date field
          if (item['date'] != null) {
            DateTime date = DateTime.parse(item['date']);
            // Add the DateTime object to the map
            item['date'] = date;
          }
          return item;
        })
        .cast<Map<String, dynamic>>()
        .toList();

    return userTransactions.reversed.take(20).toList();
  } else {
    // If the JSON string is null, return an empty list
    return [];
  }
}

Future<double> getTransactionsBenefit() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the JSON string from shared preferences
  String? jsonList = prefs.getString('transaction');

  double value = 0;

  // If the JSON string is not null, decode it back to a list
  if (jsonList != null && jsonList.isNotEmpty) {
    jsonDecode(jsonList).forEach((item) {
      if (item['transType'] == 'withdrawal') {
        value += double.parse(item['amount']);
      }
    });

    return value * 0.99;
  } else {
    // If the JSON string is null, return an empty list
    return 0;
  }
}

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
  String msg = '';
  String error = '';
  final prefs = await SharedPreferences.getInstance();
  try {
    final token = prefs.getString('token');
    final email = prefs.getString('email');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final url =
        Uri.parse('$getProduct?email=$email&seller=$sellerEmail&id=$prdtId');

    final response = await http.get(url, headers: headers);

    final jsonResponse = jsonDecode(response.body);

    msg = jsonResponse['message'] ?? '';

    if (response.statusCode == 200) {
      return jsonResponse['userPrdt'];
    } else {
      if (error == 'Accès refusé') {
        String title = "Erreur. Accès refusé.";
        showPopupMessage(context, title, msg);
      }

      String title = 'Erreur';
      showPopupMessage(context, title, msg);

      // Handle errors,
      print('something went wrong');
      return;
    }
  } catch (e) {
    print(e);
    String title = error;
    showPopupMessage(context, title, msg);
    return;
  }
}

class ScreenArguments {
  final String prdtId;
  final String sellerEmail;

  ScreenArguments(this.prdtId, this.sellerEmail);
}
