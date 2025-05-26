import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/bonuscard.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/affiliation-page-filleuls-details.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Affiliation extends StatefulWidget {
  static const id = 'affiliation';

  @override
  State<Affiliation> createState() => _AffiliationState();
}

class _AffiliationState extends State<Affiliation> {
  String? code;
  String? link;
  String? partnerPack;
  bool showSpinner = true;
  bool isCode = true;
  String email = '';
  int directCount = 0;
  int indirectCount = 0;
  late SharedPreferences prefs;

  int basicRequirements = 2000;
  int proRequirements = 5000;
  int goldRequirements = 10000;

  int directSubCount = 0;
  int directNonSubCount = 0;
  int indirectSubCount = 0;
  int indirectNonSubCount = 0;

  final ApiService apiService = ApiService();

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    code = prefs.getString('code');
    email = prefs.getString('email') ?? '';
    partnerPack = prefs.getString('partnerPack') ?? '';

    // Construct the URI
    Uri uri = Uri.parse('${frontEnd}inscription')
        .replace(queryParameters: {'affiliationCode': code});

    link = uri.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await getInfos();
      setState(() => showSpinner = false);
    } catch (e) {
      print(e);
      setState(() => showSpinner = false);
    }
  }

  Future<void> refreshPage() async {
    if (mounted) {
      await initSharedPref();
      setState(() {});
    }
  }

  Future<void> getInfos() async {
    setState(() => showSpinner = true);

    try {
      await initSharedPref();

      final response = await apiService.getReferralStats();

      String msg = response.message;
      int? statusCode = response.statusCode;

      if (statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300 &&
          response.apiReportedSuccess) {
        final responseData = response.body['data'] ?? {};
        directCount = responseData['level1Count'] ?? 0;
        indirectCount = (responseData['level2Count'] ?? 0) +
            (responseData['level3Count'] ?? 0);
        directSubCount = responseData['level1ActiveSubscribers'] ?? 0;
        indirectSubCount = (responseData['level2ActiveSubscribers'] ?? 0) +
            (responseData['level3ActiveSubscribers'] ?? 0);

        print('Referral stats fetched successfully');
      } else {
        String error = response.message;
        if (error == 'Accès refusé') {
          showPopupMessage(context, "Erreur. Accès refusé.", msg);
          await logoutUser();
        } else {
          String title = 'Erreur';
          showPopupMessage(context, title, msg.isNotEmpty ? msg : error);
        }
        print('API Error getInfos (Affiliation): $statusCode - $error - $msg');
      }
    } catch (e) {
      print('Exception in getInfos (Affiliation): $e');
      String title = context.translate('error');
      showPopupMessage(context, title, context.translate('error_occurred'));
    } finally {
      if (mounted) {
        setState(() => showSpinner = false);
      }
    }
  }

  Future<void> logoutUser() async {
    if (!kIsWeb) {
      final avatar = prefs.getString('avatar') ?? '';
      await deleteFile(avatar);
    }
    await prefs.clear();
    await deleteNotifications();
    await deleteAllKindTransactions();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    print(partnerPack);

    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    String? copy = isCode ? code : link;
    final directL = directCount;
    final indirectL = indirectCount;

    final directSubL = directSubCount;
    final indirectSubL = indirectSubCount;

    final basic = (directSubL / basicRequirements) * 100;
    final pro = (directSubL / proRequirements) * 100;
    final gold = (directSubL / goldRequirements) * 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.translate('your_affiliates'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: code != null
            ? RefreshIndicator(
                onRefresh: getInfos,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(24 * fem),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Affiliation Code/Link Switcher
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8 * fem),
                                color: Colors.grey[200],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTab(
                                      text: context.translate('sponsor_code'),
                                      isSelected: isCode,
                                      onTap: () =>
                                          setState(() => isCode = true),
                                      fem: fem,
                                      ffem: ffem,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildTab(
                                      text: context.translate('sponsor_link'),
                                      isSelected: !isCode,
                                      onTap: () =>
                                          setState(() => isCode = false),
                                      fem: fem,
                                      ffem: ffem,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16 * fem),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * fem,
                                vertical: 16 * fem,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12 * fem),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      copy ?? '',
                                      style: TextStyle(
                                        fontSize: 14 * ffem,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy),
                                    onPressed: () =>
                                        copyToClipboard(context, copy ?? ''),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24 * fem),

                        // Stats Card
                        Container(
                          padding: EdgeInsets.all(16 * fem),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12 * fem),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              context.pushNamed(
                                Filleuls.id,
                                extra: email,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.translate('direct_godchilds'),
                                      style: TextStyle(
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      directL.toString(),
                                      style: TextStyle(
                                        fontSize: 22 * ffem,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16 * fem),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.translate('indirect_godchilds'),
                                      style: TextStyle(
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      indirectL.toString(),
                                      style: TextStyle(
                                        fontSize: 22 * ffem,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8 * fem),
                                Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24 * fem),

                        // Bonuses Section
                        if (partnerPack != null &&
                            (partnerPack == 'basic' || partnerPack == 'gold'))
                          Column(
                            children: [
                              Text(
                                context.translate('bonus_to_win'),
                                style: TextStyle(
                                  fontSize: 18 * ffem,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 16 * fem),
                              BonusCard(
                                type: 1,
                                percentage: basic,
                              ),
                              SizedBox(height: 16 * fem),
                              BonusCard(
                                type: 2,
                                percentage: pro,
                              ),
                              SizedBox(height: 16 * fem),
                              BonusCard(
                                type: 3,
                                percentage: gold,
                              ),
                              SizedBox(height: 24 * fem),

                              // Shares Count
                              Text(
                                context.translate('number_of_shares',
                                    args: {'count': 0}),
                                style: TextStyle(
                                  fontSize: 18 * ffem,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              )
            : (code == null)
                ? Center(
                    child: Text(
                      context.translate('no_affiliation_code'),
                      style: TextStyle(
                        fontSize: 16 * ffem,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : SizedBox(),
      ),
    );
  }

  Widget _buildTab({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required double fem,
    required double ffem,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12 * fem,
          horizontal: 16 * fem,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8 * fem),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14 * ffem,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
