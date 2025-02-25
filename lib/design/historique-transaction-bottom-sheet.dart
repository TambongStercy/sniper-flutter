import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/historycard.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Assuming you have this for context.translate
import 'package:http/http.dart' as http;

class BottomHitory extends StatefulWidget {
  final String? type;

  BottomHitory({this.type});

  @override
  State<BottomHitory> createState() => _BottomHitoryState();
}

class _BottomHitoryState extends State<BottomHitory> {
  @override
  void initState() {
    super.initState();
    initSharedPref().then((_) {
      if (mounted) {
        getUserTransactions();
      }
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.8) && hasMore) {
      getUserTransactions();
    }
  }

  String email = '';
  bool showSpinner = true;
  late SharedPreferences prefs;
  String? errorMessage;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
  }

  final scrollController = ScrollController();

  String get link =>
      widget.type == 'partner' ? getPartnerTransactions : getTransactions;

  int page = 1;
  bool isLoading = false;
  int totalPages = 0;
  int itemCount = 0;
  bool hasMore = true;

  Future<void> getUserTransactions() async {
    if (isLoading || !hasMore || !mounted) return;

    isLoading = true;
    if (mounted) setState(() {});

    try {
      final token = prefs.getString('token');
      final uri = Uri.parse('${link}?email=$email&page=$page&limit=20');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var response = await http.get(uri, headers: headers);
      final jsonResponse = json.decode(response.body);
      final msg = jsonResponse['message'] ?? '';

      if (response.statusCode == 200) {
        final jsonTransactions = jsonResponse['transactions'];
        totalPages = jsonResponse['totalPages'];

        page++;
        isLoading = false;

        if (jsonTransactions == null ||
            jsonTransactions.length < 20 ||
            page >= totalPages) {
          hasMore = false;
        }

        List<Map<String, dynamic>> newTrans =
            (jsonTransactions as List).map((item) {
          if (item['date'] != null) {
            DateTime date = DateTime.parse(item['date']);
            item['date'] = date;
          }
          return item as Map<String, dynamic>;
        }).toList();

        transactions.addAll(newTrans);
        itemCount = transactions.length;

        if (mounted) setState(() {});
      } else {
        errorMessage = msg;
        if (mounted) setState(() {});
      }
    } catch (e) {
      errorMessage = e.toString();
      if (mounted) setState(() {});
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  void showError(BuildContext context) {
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showPopupMessage(context, context.translate('error'), errorMessage!);
        errorMessage = null;
      });
    }
  }

  Future<void> refresh() async {
    transactions.clear();
    itemCount = 0;
    page = 1;
    hasMore = true;
    if (mounted) setState(() {});

    await getUserTransactions();
  }

  final List<Map<String, dynamic>> transactions = [];

  @override
  Widget build(BuildContext context) {
    showError(context);

    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25 * fem),
          topRight: Radius.circular(25 * fem),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20 * fem, bottom: 15 * fem),
            padding: EdgeInsets.symmetric(horizontal: 25 * fem),
            child: Text(
              context.translate('transaction_history'),
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 20 * ffem,
                fontWeight: FontWeight.w500,
                height: 1 * ffem / fem,
                color: const Color(0xff25313c),
              ),
            ),
          ),
          Flexible(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 25 * fem),
                child: ListView.builder(
                  controller: scrollController,
                  itemBuilder: ((context, index) {
                    if (index < transactions.length) {
                      final trans = transactions[index];
                      final date = formatTime(trans['date']);
                      final isDeposit = trans['transType'] == 'deposit';
                      final amount = trans['amount'] != null
                          ? double.tryParse(trans['amount'].toString())?.floor() ?? 0
                          : 0;

                      final pending = trans['status'] != null &&
                          trans['status'] == 'pending';

                      return HistoryCard(
                        time: date,
                        deposit: isDeposit,
                        amount: amount,
                        pending: pending,
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: hasMore
                              ? const CircularProgressIndicator()
                              : Text(context.translate('no_more_transactions')),
                        ),
                      );
                    }
                  }),
                  itemCount: transactions.length + 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
