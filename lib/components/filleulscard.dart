import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:snipper_frontend/utils.dart';

class FilleulsCard extends StatelessWidget {
  const FilleulsCard({
    super.key,
    this.image,
    this.buffer = '',
    required this.name,
    required this.email,
  });

  final String? image;
  final String buffer;
  final String name;
  final String email;

  ImageProvider<Object> _imageBuffer() {
    if (buffer != '') {
      final Uint8List bytes = Uint8List.fromList(base64.decode(buffer));

      return MemoryImage(bytes);
    }

    return const AssetImage(
      'assets/design/images/your picture.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      width: double.infinity,
      height: 70 * fem,
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(4 * fem),
      ),
      child: ListTile(
        leading: Container(
          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 15 * fem, 0 * fem),
          width: 40 * fem,
          height: 40 * fem,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * fem),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: _imageBuffer(),
            ),
          ),
        ),
        title: Text(
          name,
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 16 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.0625 * ffem / fem,
            letterSpacing: -0.5 * fem,
            color: Color(0xff25313c),
          ),
        ),
        subtitle: Text(
          email,
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 12 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.4166666667 * ffem / fem,
            letterSpacing: -0.5 * fem,
            color: Color(0xff6d7d8b),
          ),
        ),
      ),
    );
  }
}
