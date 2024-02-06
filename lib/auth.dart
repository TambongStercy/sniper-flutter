// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snipper_frontend/config.dart';
// import 'package:snipper_frontend/utils.dart';
// import 'package:http/http.dart' as http;

// void initSharedPref() async {
//   prefs = await SharedPreferences.getInstance();
// }

// class Auth {



//   void registerUser(context) async {
//     if (name.isNotEmpty &&
//         pw.isNotEmpty &&
//         name.isNotEmpty &&
//         email.isNotEmpty &&
//         pw.isNotEmpty &&
//         pwconfirm.isNotEmpty &&
//         whatsapp.isNotEmpty &&
//         city.isNotEmpty &&
//         code.isNotEmpty) {

//       var regBody = {
//         'name': name,
//         'email': email,
//         'password': pw,
//         'confirm': pwconfirm,
//         'phone': whatsapp,
//         'region': city,
//         'code': code,
//       };

//       final prefs = await SharedPreferences.getInstance();

//       var response = await http.post(
//         Uri.parse(registration),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(regBody),
//       );


//       var jsonResponse = jsonDecode(response.body);

//       var myToken = jsonResponse['token'];

//       if (myToken != null) {
//         prefs.setString('token', myToken);
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => Accueil()),
//         );
//       } else {
//         String msg = 'Please Try again';
//         String title = 'Something went wrong';
//         showPopupMessage(context, title, msg);
//       }
//     } else {
//       String msg = 'Please fill in all information asked';
//       String title = 'Information not complete';
//       showPopupMessage(context, title, msg);
//     }
//   }
// }
