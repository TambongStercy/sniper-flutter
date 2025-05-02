import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/utils.dart';

class FilleulsCard extends StatefulWidget {
  const FilleulsCard({
    super.key,
    this.image,
    this.buffer = '',
    required this.name,
    required this.email,
    this.url,
    this.subscriptionType,
  });

  final String? image;
  final String buffer;
  final String name;
  final String email;
  final String? url;
  final String? subscriptionType;

  @override
  State<FilleulsCard> createState() => _FilleulsCardState();
}

class _FilleulsCardState extends State<FilleulsCard> {
  ImageProvider<Object> _imageBuffer() {
    if (widget.buffer != '') {
      final Uint8List bytes = Uint8List.fromList(base64.decode(widget.buffer));

      return MemoryImage(bytes);
    }

    if (widget.url != null && widget.url!.isNotEmpty) {
      return NetworkImage(widget.url!);
    }

    return const AssetImage(
      'assets/design/images/your picture.png',
    );
  }

  late SharedPreferences prefs;
  String email = '';
  bool isSubscribed = false;
  bool isPartner = false;

  String getWaLink() {
    return "";
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    isPartner = prefs.getString('partnerPack') != null;
  }

  @override
  void initState() {
    super.initState();

    () async {
      await initSharedPref();
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    // Determine badge based on subscriptionType
    Widget? trailingBadge;
    if (widget.subscriptionType != null) {
      String badgeAsset =
          'assets/assets/images/Certified - Blue.png'; // Default to Blue for 'classique' or others
      if (widget.subscriptionType!.toLowerCase() == 'cible') {
        badgeAsset = 'assets/assets/images/Certified - Orange.png';
      }
      // You can add more else if conditions here for other subscription types
      trailingBadge = Image.asset(
        badgeAsset,
        width: 30,
        height: 30,
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(4 * fem),
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.fromLTRB(20 * fem, 0 * fem, 20 * fem, 0 * fem),
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
        title: Text(
          widget.name,
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 16 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.0625 * ffem / fem,
            letterSpacing: -0.5 * fem,
            color: Color(0xff25313c),
          ),
        ),
        subtitle: InkWell(
          onTap: () {
            sendWhatsAppMessage(context, widget.name, widget.email);
            // https://wa.link/bht6g7
          },
          child: Text(
            widget.email,
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
        trailing: trailingBadge, // Use the determined badge widget
      ),
    );
  }
}
