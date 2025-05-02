import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:snipper_frontend/utils.dart';

class SimpleScaffold extends StatelessWidget {
  static const id = 'wallet';

  final String title;
  final Color? appBarColor;
  final Widget child;
  final bool? inAsyncCall;
  final List<Widget>? actions;

  const SimpleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.inAsyncCall,
    this.appBarColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: appBarColor == null ? Colors.white : appBarColor,
        actions: actions,
        title: Text(
          title,
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 16 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.6666666667 * ffem / fem,
            color: Theme.of(context).colorScheme.onSurface,
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
