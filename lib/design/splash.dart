import 'package:flutter/material.dart';

class Scene extends StatelessWidget {
  static const id = 'splash';

  const Scene({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 240,
          height: 100,
          child: Image.asset(
            'assets/design/images/logo-sbc-final-2.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
