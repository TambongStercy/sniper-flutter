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
    required this.url,
    required this.isSub,
  });

  final String? image;
  final String buffer;
  final String name;
  final String email;
  final String url;
  final bool isSub;

  ImageProvider<Object> _imageBuffer() {
    if (buffer != '') {
      final Uint8List bytes = Uint8List.fromList(base64.decode(buffer));

      return MemoryImage(bytes);
    }

    if (url != '') {
      return NetworkImage(url);
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
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(4 * fem),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(20 * fem, 0 * fem, 20 * fem, 0 * fem),
        leading: Container(
          margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
          width: 35 * fem,
          height: 35 * fem,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * fem),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: _imageBuffer(),
            ),
          ),
        ),
        trailing: isSub
            ? TextButton(
                onPressed: () {},
                child: const Text(
                  'actif',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff1862f0),
                  ),
                ),
              )
            : const SizedBox(),
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
