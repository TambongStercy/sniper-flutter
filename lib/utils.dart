import 'dart:convert';

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/config.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

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
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String filePath = '${appDocumentsDirectory.path}/$folder/$fileName';

  final imageDirectory = Directory('${appDocumentsDirectory.path}/$folder');
  if (!imageDirectory.existsSync()) {
    imageDirectory.createSync(recursive: true);
  }

  final fileBytes = await readFileBytes(path);

  File file = File(filePath);

  if (file.existsSync()) {
    await deleteFile(filePath);
  }

  await file.writeAsBytes(fileBytes);

  print('File saved to: $filePath');

  return filePath;
}

Future<String> saveFileBytesLocally(
    String folder, String fileName, List<int> fileBytes) async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String filePath = '${appDocumentsDirectory.path}/$folder/$fileName';

  final imageDirectory = Directory('${appDocumentsDirectory.path}/$folder');
  if (!imageDirectory.existsSync()) {
    imageDirectory.createSync(recursive: true);
  }

  File file = File(filePath);
  await file.writeAsBytes(fileBytes);

  print('File saved to: $filePath');

  return filePath;
}

Future<String> mobilePathGetter(String simplePath) async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  return '${appDocumentsDirectory.path}/$simplePath';
}

Future<List<int>> readFileBytes(String filePath) async {
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

bool ppExist(String path) {
  return path.isNotEmpty && File(path).existsSync();
}

ImageProvider<Object> profileImage(String avatarPath) {
  if (ppExist(avatarPath)) {
    print('avatarPath please call setState: $avatarPath');

    // Check if the user's profile picture path is not empty and the file exists.

    return FileImage(File(avatarPath));
  }
  // Return the default profile picture from the asset folder.
  return const AssetImage(
    'assets/design/images/your picture.png',
  );
}

Future<void> deleteFile(String filePath) async {
  try {
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
      print('File deleted successfully');
    } else {
      print('File does not exist');
    }
  } catch (e) {
    print('Error deleting file: $e');
  }
}

Future<void> launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

//Initialize notification handleing
Future<void> initializeOneSignal(String extId) async {


  OneSignal.initialize(onesignalAppId);

  /// notification external id
  await OneSignal.login(extId);

  // addCallbackOnNotif(duringNotification);
  OneSignal.Notifications.removeForegroundWillDisplayListener(
      duringNotification);

  OneSignal.Notifications.addForegroundWillDisplayListener(duringNotification);
}

void addCallbackOnNotif(callback) {
  print('adding callback');
  OneSignal.Notifications.removeForegroundWillDisplayListener(callback);

  // OneSignal.Notifications.clearAll();
  OneSignal.Notifications.addForegroundWillDisplayListener(callback);
}

Future<void> unInitializeOneSignal() async {
  OneSignal.Notifications.removeForegroundWillDisplayListener(
      duringNotification);

  OneSignal.Notifications.clearAll();
  OneSignal.logout();
}

String notifId = '';

///Is called during a notification
Future<void> duringNotification(OSNotificationWillDisplayEvent event) async {
  // Display Notification, preventDefault to not display
  // event.preventDefault();

  final notification = event.notification;

  String notificationTitle = notification.title ?? "No Title";
  String newNotifId = notification.rawPayload?['google.message_id'];

  if (newNotifId == notifId || notificationTitle == 'Sniper abonnement') {
    return print('break');
  }

  notifId = newNotifId;

  if (notificationTitle == 'Sniper transaction') {
    final message = (notification.body) ?? '';
    Map<String, String> notif = {
      'message': message,
      'titile': notificationTitle,
    };
    saveNotification(notif);
  } else if (notificationTitle == 'Sniper abonnement') {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSubscribed', true);
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

  print('saving');
  // Convert the list to a JSON string
  String jsonList = jsonEncode(transactions);

  print(jsonList);

  // Save the JSON string to shared preferences
  prefs.setString('transaction', jsonList);
}

Future<void> deleteTransactions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Save the JSON string to shared preferences
  prefs.setString('transaction', '');
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

    return userTransactions;
  } else {
    // If the JSON string is null, return an empty list
    return [];
  }
}

String formatTime(DateTime dateTime) {
  // Format the time as HH:MM AM/PM
  String formattedTime =
      "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ";

  // Determine whether it's AM or PM
  formattedTime += (dateTime.hour < 12) ? 'AM' : 'PM';

  return formattedTime;
}