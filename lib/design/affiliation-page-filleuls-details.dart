import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/filleulscard.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/utils.dart';

class Filleuls extends StatelessWidget {
  static const id = 'filleuls';

  final String email;
  final List directUsers;
  final List indirectUsers;

  Filleuls({
    super.key,
    required this.email,
    required this.directUsers,
    required this.indirectUsers,
  });

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: 'Vos filleus',
      child: Container(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.fromLTRB(0 * fem, 26 * fem, 0 * fem, 26 * fem),
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
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 15 * fem),
                      child: Text(
                        'Filleuls direct',
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 14 * ffem,
                          fontWeight: FontWeight.w500,
                          height: 1.4285714286 * ffem / fem,
                          color: Color(0xfff49101),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 16 * fem),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: directUsers.map((user) {
                                return FilleulsCard(
                                  isSub: user['isSubscribed'],
                                  url: user['url'],
                                  buffer: user['avatar'],
                                  name: user['name'],
                                  email: user['email'].toString(),
                                );
                              }).toList(),
                             ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 15 * fem),
                      child: Text(
                        'Filleuls indirect',
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 14 * ffem,
                          fontWeight: FontWeight.w500,
                          height: 1.4285714286 * ffem / fem,
                          color: Color(0xfff49101),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 16 * fem),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: indirectUsers.map((user) {
                                return FilleulsCard(
                                  isSub: user['isSubscribed'],
                                  url: user['url'],
                                  buffer: user['avatar'],
                                  name: user['name'],
                                  email: user['email'].toString(),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
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
}
