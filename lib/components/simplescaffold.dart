import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';

class SimpleScaffold extends StatelessWidget {
  static const id = 'wallet';

  final String title;
  final Color? appBarColor;
  final Widget child;
  final bool? inAsyncCall;

  const SimpleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.inAsyncCall,
    this.appBarColor,
  });

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, // Set your desired back button color
        ),
        backgroundColor: appBarColor == null ? Colors.white : appBarColor,
        title: Text(
          title,
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 16 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.6666666667 * ffem / fem,
            color: Colors.black,
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: inAsyncCall ?? false,
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }
}
