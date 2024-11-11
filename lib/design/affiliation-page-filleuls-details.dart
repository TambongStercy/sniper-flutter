import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/filleulscard.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:http/http.dart' as http;

class Filleuls extends StatefulWidget {
  static const id = 'filleuls';

  final String email;

  Filleuls({
    super.key,
    required this.email,
  });

  @override
  State<Filleuls> createState() => _FilleulsState();
}

class _FilleulsState extends State<Filleuls> {
  String email = '';
  String mainType = 'Direct';
  bool isloading = false;
  bool hasMore = true;

  List directUsers = [];
  List indirectUsers = [];

  int totalPagesDirect = 1;
  int totalPagesIndirect = 1;

  final scrollController = ScrollController();
  int page = 1;

  late SharedPreferences prefs;

  @override
  void initState() {
    getReferedUersFunc();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        getReferedUersFunc();
      }
    });
    super.initState();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
  }

  Future<void>? getReferedUersFunc() async {
    if (isloading) return;
    isloading = true;
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      final token = prefs.getString('token');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final url = Uri.parse('$getReferedUsers?email=${email}&page=${page}');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        totalPagesDirect = jsonResponse['totalPagesDirect'] ?? 1;
        totalPagesIndirect = jsonResponse['totalPagesIndirect'] ?? 1;

        final fDirectUsers = jsonResponse['directUsers'] ?? [];
        final fIndirectUsers = jsonResponse['indirectUsers'] ?? [];

        page++;
        isloading = false;

        if (fDirectUsers.length < 10 && mainType == 'Direct') hasMore = false;
        if (fIndirectUsers.length < 10 && mainType == 'Indirect')
          hasMore = false;

        if (mainType == 'Direct') directUsers.addAll(fDirectUsers);
        if (mainType == 'Indirect') indirectUsers.addAll(fIndirectUsers);

        if (mounted) setState(() {});
      } else {
        if (error == 'Accès refusé') {
          String title = "Erreur. Accès refusé.";
          showPopupMessage(context, title, msg);

          if (!kIsWeb) {
            final avatar = prefs.getString('avatar') ?? '';

            await deleteFile(avatar);
          }

          prefs.setString('token', '');
          prefs.setString('id', '');
          prefs.setString('email', '');
          prefs.setString('name', '');
          prefs.setString('token', '');
          prefs.setString('region', '');
          prefs.setString('phone', '');
          prefs.setString('code', '');
          prefs.setString('avatar', '');
          prefs.setDouble('balance', 0);
          prefs.setBool('isSubscribed', false);
          await deleteNotifications();
          await deleteAllKindTransactions();

          context.go('/');

        }

        String title = 'Erreur';
        showPopupMessage(context, title, msg);

        // Handle errors,
        print('something went wrong');
      }
    } catch (e) {
      print(e);
      String title = error;
      showPopupMessage(context, title, msg);
    }
  }

  Future<void> refresh() async {
    setState(() {
      directUsers.clear();
      indirectUsers.clear();
      page = 1;
      hasMore = true;
    });

    await getReferedUersFunc();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: context.translate('your_godchildren'),
      child: Container(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.fromLTRB(0 * fem, 20 * fem, 0 * fem, 26 * fem),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.fromLTRB(25 * fem, 0 * fem, 25 * fem, 0 * fem),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          _topButton(fem, context.translate('direct')),
                          _topButton(fem, context.translate('indirect')),
                        ],
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: refresh,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 16 * fem),
                        width: double.infinity,
                        child: ListView.builder(
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: (mainType == context.translate('direct')
                                  ? directUsers.length
                                  : indirectUsers.length) +
                              (hasMore ? 1 : 0),
                          padding: EdgeInsets.all(8.0),
                          itemBuilder: ((context, index) {
                            final usersUsed =
                                mainType == context.translate('direct')
                                    ? directUsers
                                    : indirectUsers;

                            final itemCount = usersUsed.length;

                            if (index < itemCount) {
                              final user = usersUsed[index];

                              return FilleulsCard(
                                isSub: user['isSubscribed'],
                                url: user['url'],
                                buffer: user['avatar'],
                                name: user['name'],
                                email: user['email'].toString(),
                              );
                            } else if (hasMore) {
                              // Only show CircularProgressIndicator if more data is loading
                              return Padding(
                                padding: EdgeInsets.all(0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            } else {
                              // Avoid showing anything if there's no more data to load
                              return SizedBox.shrink();
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _topButton(double fem, String type) {
    final capsType = type.length > 2
        ? type.substring(0, 1).toUpperCase() + type.substring(1)
        : type;

    return Expanded(
      child: InkWell(
        onTap: () async {
          setState(() {
            mainType = type;
          });
          await refresh();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10 * fem,
            horizontal: 30 * fem,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10 * fem)),
            color: mainType == type ? blue : Colors.grey[200],
          ),
          child: Text(
            capsType,
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'Mulish',
              height: 1.255,
              color: mainType == type ? Color(0xffffffff) : Color(0xff000000),
            ),
          ),
        ),
      ),
    );
  }
}
