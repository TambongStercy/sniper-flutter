import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/wallet_card.dart';
import 'package:snipper_frontend/components/rewards_card.dart';
import 'package:snipper_frontend/components/quick_actions.dart';
import 'package:snipper_frontend/components/transaction_record.dart';
import 'package:snipper_frontend/components/modern_tabs.dart';
import 'package:snipper_frontend/design/historique-transaction-bottom-sheet.dart';
import 'package:snipper_frontend/design/retrait.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/components/transaction_detail_modal.dart';
import 'package:intl/intl.dart';

class Wallet extends StatefulWidget {
  static const id = 'wallet';

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  double balance = 0;
  double benefice = 0;
  String email = '';
  String name = '';
  String momoNumber = '';
  String momoCor = '';
  bool showSpinner = true;
  int _selectedTabIndex = 0;

  // Add state variables for stats
  int completedDeposits = 0;
  double totalDepositAmount = 0.0;
  int pendingDeposits = 0;
  int completedWithdrawals = 0;
  double totalWithdrawalAmount = 0.0;
  int pendingWithdrawals = 0;

  // Mock transactions for demo purposes
  final List<Map<String, dynamic>> _recentTransactions = [];
  final List<Map<String, dynamic>> _pendingTransactions = [];

  late SharedPreferences prefs;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();

    // Create anonymous function:
    () async {
      try {
        await getInfos();
        await _fetchTransactions();

        setState(() {
          showSpinner = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          showSpinner = false;
        });
      }
    }();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      // Optional: show a specific loading indicator for transactions if desired
      // showSpinner = true; // Or a more granular loading state
    });

    _recentTransactions.clear();
    _pendingTransactions.clear();

    try {
      // Fetch completed transactions (recent)
      final completedResponse = await _apiService.getTransactions({
        'status': 'completed',
        'limit': '5', // Fetch latest 5 completed
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      });

      if (completedResponse['success'] == true &&
          completedResponse['transactions'] != null) {
        final List<dynamic> jsonTransactions =
            completedResponse['transactions'];
        _recentTransactions
            .addAll(_processFetchedTransactions(jsonTransactions));
      } else {
        print(
            'Error fetching completed transactions: ${completedResponse['message'] ?? completedResponse['error']}');
        // Optionally show a specific error message to the user for recent transactions
      }

      // Fetch pending transactions
      final pendingResponse = await _apiService.getTransactions({
        'status': 'pending',
        'limit': '5', // Fetch latest 5 pending
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      });

      if (pendingResponse['success'] == true &&
          pendingResponse['transactions'] != null) {
        final List<dynamic> jsonTransactions = pendingResponse['transactions'];
        _pendingTransactions
            .addAll(_processFetchedTransactions(jsonTransactions));
      } else {
        print(
            'Error fetching pending transactions: ${pendingResponse['message'] ?? pendingResponse['error']}');
        // Optionally show a specific error message to the user for pending transactions
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      // Optionally show a generic error message to the user
      if (mounted) {
        showPopupMessage(context, context.translate('error'),
            context.translate('error_fetching_transactions'));
      }
    } finally {
      if (mounted) {
        setState(() {
          // showSpinner = false; // Hide general spinner if it was shown at the start
        });
      }
    }
  }

  List<Map<String, dynamic>> _processFetchedTransactions(
      List<dynamic> jsonTransactions) {
    List<Map<String, dynamic>> processedTransactions = [];
    final DateFormat outputFormat = DateFormat('dd/MM/yyyy');

    for (var item in jsonTransactions) {
      if (item is Map<String, dynamic>) {
        try {
          final createdAtString = item['createdAt'] as String?;
          DateTime? parsedDate;
          if (createdAtString != null) {
            parsedDate = DateTime.tryParse(createdAtString);
          }

          final type = item['type'] as String? ?? 'unknown';
          final transactionId = item['transactionId'] as String?;

          if (parsedDate == null || transactionId == null) {
            print("Skipping transaction due to missing date or ID: $item");
            continue;
          }

          String title;
          if (type == 'deposit') {
            title = context.translate('deposit');
          } else if (type == 'withdrawal') {
            title = context.translate('withdrawal');
          } else {
            title = context.translate('unknown_transaction'); // Add this key
          }

          processedTransactions.add({
            'transactionId': transactionId,
            'title': title,
            'date': outputFormat.format(parsedDate),
            'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
            'isDeposit': type == 'deposit',
            // 'currency': item['currency'] as String? ?? 'XAF', // If needed by TransactionRecord
          });
        } catch (e) {
          print("Error processing a transaction item: $item, Error: $e");
        }
      }
    }
    return processedTransactions;
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    balance = (prefs.getDouble('balance') ?? 0).floorToDouble();
    email = prefs.getString('email') ?? '';
    benefice = (prefs.getDouble('benefit') ?? 0).floorToDouble();
    momoNumber = prefs.getString('momo') ?? '';
    momoCor = prefs.getString('momoCorrespondent') ?? '';
  }

  refreshPage() {
    if (mounted) {
      initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }
  }

  Future<void> getInfos() async {
    try {
      setState(() {
        showSpinner = true;
      });

      await initSharedPref();

      // Fetch both profile and transaction stats concurrently
      final profileFuture = _apiService.getUserProfile();
      final statsFuture = _apiService.getTransactionStats().catchError((e) {
        print('Error fetching transaction stats: $e');
        // Return a default response structure to avoid breaking the UI
        return {
          'success': false,
          'error': 'Failed to load transaction stats',
          'stats': {
            'deposit': {
              'completed': {'count': 0, 'totalAmount': 0},
              'pending': {'count': 0}
            },
            'withdrawal': {
              'completed': {'count': 0, 'totalAmount': 0},
              'pending': {'count': 0}
            }
          }
        };
      });

      // Wait for both API calls to complete
      final results = await Future.wait([profileFuture, statsFuture]);
      final profileResponse = results[0] as Map<String, dynamic>;
      final statsResponse = results[1] as Map<String, dynamic>;

      String msg = '';

      // Process Profile Response
      if (profileResponse['success'] == true &&
          profileResponse['data'] != null) {
        final userData = profileResponse['data'] as Map<String, dynamic>;
        final fetchedEmail = userData['email'] as String? ?? email;
        final fetchedBalance =
            (userData['balance'] as num?)?.toDouble() ?? balance;
        final fetchedTotalBenefits =
            (userData['totalBenefits'] as num?)?.toDouble() ?? benefice;
        final fetchedMomoNumber =
            userData['momoNumber']?.toString() ?? momoNumber;
        final fetchedMomoCor = userData['momoOperator']?.toString() ?? momoCor;

        setState(() {
          email = fetchedEmail;
          balance = fetchedBalance.floorToDouble();
          benefice = fetchedTotalBenefits
              .floorToDouble(); // Update local benefit state
          momoNumber = fetchedMomoNumber;
          momoCor = fetchedMomoCor;
        });

        print('User info updated successfully');
      } else {
        // Handle API error response
        msg = profileResponse['message'] ??
            profileResponse['error'] ??
            'Failed to fetch user info';
        final statusCode = profileResponse['statusCode'];

        if (statusCode == 401) {
          String title = context.translate('error_access_denied');
          showPopupMessage(context, title, msg, callback: () async {
            // Perform logout actions
            if (!kIsWeb) {
              final avatar = prefs.getString('avatar') ?? '';
              if (avatar.isNotEmpty) await deleteFile(avatar);
            }
            await prefs.clear();
            await deleteNotifications();
            await deleteAllKindTransactions();
            if (mounted) context.go('/');
          });
        } else {
          String title = context.translate('error');
          showPopupMessage(context, title, msg);
        }
        print('Error fetching user info: $msg');
      }

      // Process Stats Response
      if (statsResponse['success'] == true && statsResponse['stats'] != null) {
        final stats = statsResponse['stats'] as Map<String, dynamic>;

        // Safely extract stats data
        final depositStats = stats['deposit'] as Map<String, dynamic>?;
        final withdrawalStats = stats['withdrawal'] as Map<String, dynamic>?;

        setState(() {
          completedDeposits =
              (depositStats?['completed']?['count'] as int?) ?? 0;
          totalDepositAmount =
              (depositStats?['completed']?['totalAmount'] as num?)
                      ?.toDouble() ??
                  0.0;
          pendingDeposits = (depositStats?['pending']?['count'] as int?) ?? 0;

          completedWithdrawals =
              (withdrawalStats?['completed']?['count'] as int?) ?? 0;
          totalWithdrawalAmount =
              (withdrawalStats?['completed']?['totalAmount'] as num?)
                      ?.toDouble() ??
                  0.0;
          pendingWithdrawals =
              (withdrawalStats?['pending']?['count'] as int?) ?? 0;
        });

        print('Transaction stats updated successfully');
      } else if (!statsResponse['success']) {
        // Log the error but don't show to user since profile info was updated
        print('Stats API error: ${statsResponse['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error in getInfos: $e');
      String title = context.translate('error');
      showPopupMessage(context, title, e.toString());
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _onTransactionTapped(String transactionId) async {
    // Show loading indicator while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _apiService.getTransactionById(transactionId);
      Navigator.pop(context); // Close loading indicator

      if (response['success'] == true && response['transaction'] != null) {
        final transactionData = response['transaction'] as Map<String, dynamic>;
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
        final errorMsg = response['message'] ??
            response['error'] ??
            context.translate('error_fetching_details');
        if (mounted) {
          showPopupMessage(context, context.translate('error'), errorMsg);
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading indicator on error
      print("Exception fetching transaction details: $e");
      if (mounted) {
        showPopupMessage(context, context.translate('error'),
            context.translate('error_occurred'));
      }
    }
  }

  void _navigateToWithdraw() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Retrait()),
    ).then((_) => refreshPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          context.translate('wallet'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: showSpinner
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await getInfos();
                await _fetchTransactions();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: WalletCard(
                        balance: balance,
                        currencySymbol: "FCFA", // Use appropriate currency
                        onDepositPressed: () {
                          // Handle deposit action
                        },
                        onWithdrawPressed: _navigateToWithdraw,
                        onTransferPressed: () {
                          // Handle transfer action
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RewardsCard(
                        rewardsBalance: benefice,
                        currencySymbol: "FCFA", // Use appropriate currency
                        onViewDetailsPressed: () {}, // Pass an empty function
                      ),
                    ),
                    const SizedBox(height: 24),

                    // New Transaction Stats Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TransactionStatsDisplay(
                        completedDeposits: completedDeposits,
                        totalDepositAmount: totalDepositAmount,
                        pendingDeposits: pendingDeposits,
                        completedWithdrawals: completedWithdrawals,
                        totalWithdrawalAmount: totalWithdrawalAmount,
                        pendingWithdrawals: pendingWithdrawals,
                        currencySymbol:
                            "FCFA", // Or your desired currency symbol
                      ),
                    ),
                    const SizedBox(height: 24), // Spacing after stats

                    // Add "View Transaction History" button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              Size(double.infinity, 48), // Make button wider
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => BottomHitory(),
                          );
                        },
                        child: Text(context.translate('transaction_history')),
                      ),
                    ),

                    const SizedBox(height: 16), // Keep or adjust this spacing
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ModernTabs(
                        tabs: [
                          context.translate('recent'),
                          context.translate('pending'),
                        ],
                        selectedIndex: _selectedTabIndex,
                        onTabSelected: _onTabChanged,
                      ),
                    ),
                    if (_selectedTabIndex == 0)
                      _buildTransactionsList(_recentTransactions)
                    else
                      _buildTransactionsList(_pendingTransactions),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTransactionsList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            context.translate('no_transactions'),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      children: transactions.map((transaction) {
        return TransactionRecord(
          title: transaction['title'],
          date: transaction['date'],
          amount: transaction['amount'],
          isDeposit: transaction['isDeposit'],
          currencySymbol: "FCFA", // Use appropriate currency
          onTap: () =>
              _onTransactionTapped(transaction['transactionId'] as String),
        );
      }).toList(),
    );
  }
}

// New Widget for displaying transaction statistics
class TransactionStatsDisplay extends StatelessWidget {
  final int completedDeposits;
  final double totalDepositAmount;
  final int pendingDeposits;
  final int completedWithdrawals;
  final double totalWithdrawalAmount;
  final int pendingWithdrawals;
  final String currencySymbol;

  const TransactionStatsDisplay({
    Key? key,
    required this.completedDeposits,
    required this.totalDepositAmount,
    required this.pendingDeposits,
    required this.completedWithdrawals,
    required this.totalWithdrawalAmount,
    required this.pendingWithdrawals,
    required this.currencySymbol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('transaction_statistics'), // New translation key
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            context,
            label: context.translate('completed_deposits'), // New key
            count: completedDeposits,
            amount: totalDepositAmount,
          ),
          _buildStatRow(
            context,
            label: context.translate('pending_deposits'), // New key
            count: pendingDeposits,
          ),
          const Divider(height: 24, thickness: 1),
          _buildStatRow(
            context,
            label: context.translate('completed_withdrawals'), // New key
            count: completedWithdrawals,
            amount: totalWithdrawalAmount,
          ),
          _buildStatRow(
            context,
            label: context.translate('pending_withdrawals'), // New key
            count: pendingWithdrawals,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context,
      {required String label, required int count, double? amount}) {
    String valueText = '$count';
    if (amount != null) {
      // Format amount with currency symbol
      final formattedAmount = NumberFormat.currency(
        locale: 'fr_FR', // Adjust locale as needed for FCFA formatting
        symbol: '$currencySymbol ',
        decimalDigits: 0, // No decimal digits for FCFA in this context
      ).format(amount);
      valueText += ' ($formattedAmount)';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.black87)),
          Text(valueText,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}
