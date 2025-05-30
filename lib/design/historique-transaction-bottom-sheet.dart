import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/historycard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Assuming you have this for context.translate
import 'package:snipper_frontend/components/transaction_detail_modal.dart'; // Import the new modal widget

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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading || !hasMore) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.8)) {
      getUserTransactions();
    }
  }

  String email = '';
  bool showSpinner = true;
  late SharedPreferences prefs;
  String? errorMessage;
  final ApiService _apiService = ApiService();

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
  }

  final scrollController = ScrollController();

  int page = 1;
  bool isLoading = false;
  int itemCount = 0;
  bool hasMore = true;
  final List<Map<String, dynamic>> transactions = [];

  Future<void> getUserTransactions() async {
    if (isLoading || !hasMore || !mounted) return;

    isLoading = true;
    if (mounted) setState(() {});

    try {
      final filters = {
        'page': page.toString(),
        'limit': '10',
        'sortBy': 'createdAt',
        'sortOrder': 'desc'
      };

      final response = widget.type == 'partner'
          ? await _apiService.getPartnerTransactions(filters)
          : await _apiService.getTransactions(filters);

      if (response.apiReportedSuccess &&
          (response.body['data'] != null ||
              response.body['transactions'] != null)) {
        final List<dynamic> jsonTransactions =
            response.body['data'] ?? response.body['transactions'];
        final pagination = response.body['pagination'] as Map<String, dynamic>?;

        List<Map<String, dynamic>> newTrans = jsonTransactions.map((item) {
          if (item is Map<String, dynamic>) {
            try {
              final transType =
                  widget.type == 'partner' ? item['transType'] : item['type'];

              item['date'] = DateTime.parse(item['createdAt']);
              item['isDeposit'] = transType == 'deposit';
              item['pending'] = item['status'] == 'pending';
              item['amount'] = (item['amount'] as num?)?.toDouble() ?? 0.0;
              item['transactionId'] = item['_id']?.toString();
              return item;
            } catch (e) {
              print("Error processing transaction item: $item, Error: $e");
              return {
                'date': DateTime.now(),
                'amount': 0.0,
                'isDeposit': false,
                'pending': false,
                'type': 'error',
                'status': 'error'
              };
            }
          } else {
            print("Skipping invalid transaction item: $item");
            return {
              'date': DateTime.now(),
              'amount': 0.0,
              'isDeposit': false,
              'pending': false,
              'type': 'error',
              'status': 'error'
            };
          }
        }).toList();

        newTrans.removeWhere((t) => t['type'] == 'error');

        print(newTrans);

        if (mounted) {
          setState(() {
            transactions.addAll(newTrans);
            itemCount = transactions.length;

            if (pagination != null) {
              final int apiLimit = pagination['limit'] as int? ?? 10;
              // Try to get current page from API, fallback to the page number that was sent in the request
              int currentPageFromApi = pagination['currentPage'] as int? ??
                  pagination['page'] as int? ??
                  page;
              // Try to get total pages from API
              int apiTotalPages = pagination['totalPages'] as int? ??
                  pagination['pages'] as int? ??
                  0;

              if (apiTotalPages > 0) {
                // If API provides a valid total number of pages
                hasMore = currentPageFromApi < apiTotalPages;
              } else {
                // Fallback if total pages isn't available or is invalid from API
                hasMore = newTrans.length == apiLimit;
              }

              if (hasMore) {
                page = currentPageFromApi + 1; // Set page for the NEXT request
              }
            } else {
              // No pagination object from API, fallback to limit check
              hasMore = newTrans.length == 10; // Assuming default limit of 10
              if (hasMore) {
                page = page + 1; // Increment current page for next request
              }
            }
          });
        }
      } else {
        final msg = response.message;
        errorMessage = msg;
        if (mounted)
          setState(() {
            hasMore = false;
          });
      }
    } catch (e) {
      print("Exception fetching transactions: $e");
      errorMessage = context.translate('error_occurred');
      if (mounted)
        setState(() {
          hasMore = false;
        });
    } finally {
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  void showError(BuildContext context) {
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showPopupMessage(context, context.translate('error'), errorMessage!);
          errorMessage = null;
        }
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

  // Function to show transaction details
  void _showTransactionDetails(String transactionId) async {
    // Show loading indicator while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _apiService.getTransactionById(transactionId);
      Navigator.pop(context); // Close loading indicator

      if (response.apiReportedSuccess && response.body['transaction'] != null) {
        final transactionData =
            response.body['transaction'] as Map<String, dynamic>;
        // Show the details modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent, // Make background transparent
          builder: (context) =>
              TransactionDetailModal(transaction: transactionData),
        );
      } else {
        // Show error popup if fetch failed
        final errorMsg = response.message;
        showPopupMessage(context, context.translate('error'), errorMsg);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading indicator on error
      print("Exception fetching transaction details: $e");
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    }
  }

  @override
  Widget build(BuildContext context) {
    showError(context);

    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * fem),
          topRight: Radius.circular(20 * fem),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(vertical: 16 * fem, horizontal: 24 * fem),
            child: Text(
              context.translate('transaction_history'),
              style: TextStyle(
                fontSize: 18 * ffem,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Flexible(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListView.builder(
                  controller: scrollController,
                  itemBuilder: ((context, index) {
                    if (index < transactions.length) {
                      final trans = transactions[index];
                      final date =
                          trans['date'] as DateTime?; // Already DateTime
                      final isDeposit = trans['isDeposit'] as bool? ?? false;
                      final amount = (trans['amount'] as num?)?.floor() ?? 0;
                      final pending = trans['pending'] as bool? ?? false;
                      final transactionId = trans['transactionId']
                          as String?; // Extract transactionId

                      if (date == null || transactionId == null) {
                        // Skip rendering if essential data is missing
                        return SizedBox.shrink();
                      }

                      return HistoryCard(
                        transactionId: transactionId, // Pass transactionId
                        dateTime: date,
                        deposit: isDeposit,
                        amount: amount,
                        pending: pending,
                        onTap:
                            _showTransactionDetails, // Pass the handler function
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: hasMore
                              ? const CircularProgressIndicator()
                              : Text(
                                  context.translate('no_more_transactions'),
                                  style: TextStyle(
                                    fontSize: 15 * ffem,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ),
                      );
                    }
                  }),
                  itemCount: transactions.length + (hasMore ? 1 : 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
