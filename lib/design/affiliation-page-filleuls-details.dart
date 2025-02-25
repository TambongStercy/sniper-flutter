import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/filleulscard.dart';
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
  String mainType = 'direct';
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

    scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.8) && hasMore) {
      getReferedUersFunc();
    }
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

      final url = Uri.parse(
          '$getReferedUsers?email=${email}&page=${page}&type=${mainType.toLowerCase()}');

      final response = await http.get(url, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      msg = jsonResponse['message'] ?? '';
      error = jsonResponse['error'] ?? '';

      if (response.statusCode == 200) {
        if (mainType == 'indirect') {
          totalPagesIndirect = jsonResponse['totalPages'] ?? 1;
          final fIndirectUsers = jsonResponse['users'] ?? [];

          if (fIndirectUsers.length < 10) hasMore = false;

          indirectUsers.addAll(fIndirectUsers);
        } else {
          totalPagesDirect = jsonResponse['totalPages'] ?? 1;
          final fDirectUsers = jsonResponse['users'] ?? [];

          if (fDirectUsers.length < 10) hasMore = false;

          directUsers.addAll(fDirectUsers);
        }

        page++;
        isloading = false;

        if (mounted) setState(() {});
      } else {
        if (error == 'Accès refusé') {
          String title = "Erreur. Accès refusé.";
          showPopupMessage(context, title, msg);

          if (!kIsWeb) {
            final avatar = prefs.getString('avatar') ?? '';

            await deleteFile(avatar);
          }

          await prefs.clear();
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, // Set your desired back button color
        ),
        backgroundColor: Colors.white,
        title: Text(
          context.translate('your_godchildren'),
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 16 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.6666666667 * ffem / fem,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Color(0xffffffff),
        child: Column(
          children: [
            Container(
              margin:
                  EdgeInsets.fromLTRB(25 * fem, 20 * fem, 25 * fem, 0 * fem),
              child: Row(
                children: [
                  _topButton(fem, context.translate('direct'), 'direct'),
                  _topButton(fem, context.translate('indirect'), 'indirect'),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.fromLTRB(25 * fem, 8 * fem, 25 * fem, 8 * fem),
                  itemCount: (mainType == 'direct'
                          ? directUsers.length
                          : indirectUsers.length) +
                      (hasMore ? 1 : 0),
                  itemBuilder: ((context, index) {
                    final usersUsed =
                        mainType == 'direct' ? directUsers : indirectUsers;
                    final itemCount = usersUsed.length;

                    if (index < itemCount) {
                      final user = usersUsed[index];
                      return FilleulsCard(
                        isSub: user['isSubscribed'],
                        url: user['url'],
                        name: user['name'],
                        email: user['email'].toString(),
                      );
                    } else if (hasMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16 * fem),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _topButton(double fem, String type, String val) {
    final capsType = type.length > 2
        ? type.substring(0, 1).toUpperCase() + type.substring(1)
        : type;

    return Expanded(
      child: InkWell(
        onTap: () async {
          setState(() {
            mainType = val;
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
            color: mainType == val ? blue : Colors.grey[200],
          ),
          child: Text(
            capsType,
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'Mulish',
              height: 1.255,
              color: mainType == val ? Color(0xffffffff) : Color(0xff000000),
            ),
          ),
        ),
      ),
    );
  }
}
