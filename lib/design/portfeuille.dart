import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart'; // Import ApiService
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/design/historique-transaction-bottom-sheet.dart';
import 'package:snipper_frontend/design/retrait.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization

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

  // Add state variables for stats
  int completedDeposits = 0;
  double totalDepositAmount = 0.0;
  int pendingDeposits = 0;
  int completedWithdrawals = 0;
  double totalWithdrawalAmount = 0.0;
  int pendingWithdrawals = 0;

  late SharedPreferences prefs;
  final ApiService _apiService = ApiService(); // Instantiate ApiService

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    balance = (prefs.getDouble('balance') ?? 0).floorToDouble();
    email = prefs.getString('email') ?? '';
    benefice = (prefs.getDouble('benefit') ?? 0).floorToDouble();
    momoNumber = prefs.getString('momo') ?? '';
    momoCor = prefs.getString('momoCorrespondent') ?? '';
  }

  @override
  void initState() {
    super.initState();

    // Create anonymous function:
    () async {
      try {
        await getInfos();

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

  refreshPage() {
    if (mounted) {
      initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }
  }

  Future<void> getInfos() async {
    String msg = '';

    try {
      await initSharedPref(); // Load initial values from prefs

      setState(() {
        showSpinner = true; // Show spinner during fetch
      });

      // Fetch Profile and Stats in parallel
      final results = await Future.wait([
        _apiService.getUserProfile(),
        _apiService.getTransactionStats(),
      ]);

      final profileResponse = results[0];
      final statsResponse = results[1];

      // Process Profile Response
      if (profileResponse['success'] == true &&
          profileResponse['data'] != null) {
        final user = profileResponse['data'];

        // Extract data safely
        final fetchedRegion = user['region'] as String?;
        final fetchedEmail = user['email'] as String? ?? email;
        final fetchedPhone = user['phoneNumber']?.toString();
        final fetchedUserCode = user['referralCode'] as String?;
        final fetchedBalance = (user['balance'] as num?)?.toDouble() ?? balance;
        final fetchedTotalBenefits =
            (user['totalBenefits'] as num?)?.toDouble() ??
                benefice; // Update benefit from totalBenefits
        final fetchedName = user['name'] as String?;
        final List<dynamic> activeSubscriptions =
            user['activeSubscriptions'] as List<dynamic>? ?? [];
        final derivedIsSubscribed = activeSubscriptions.isNotEmpty;
        final fetchedMomoNumber = user['momoNumber']?.toString() ?? momoNumber;
        final fetchedMomoCor =
            user['momoOperator']?.toString() ?? momoCor; // Use momoOperator

        // Save updated values to SharedPreferences
        await prefs.setString('name', fetchedName ?? '');
        await prefs.setString('email', fetchedEmail);
        if (fetchedRegion != null)
          await prefs.setString('region', fetchedRegion);
        if (fetchedPhone != null) await prefs.setString('phone', fetchedPhone);
        if (fetchedUserCode != null)
          await prefs.setString('code', fetchedUserCode);
        await prefs.setDouble('balance', fetchedBalance);
        await prefs.setDouble(
            'benefit', fetchedTotalBenefits); // Save fetched benefit
        await prefs.setBool('isSubscribed', derivedIsSubscribed);
        await prefs.setString('momo', fetchedMomoNumber);
        await prefs.setString('momoCorrespondent', fetchedMomoCor);

        // Update local state variables for the UI
        setState(() {
          name = fetchedName ?? '';
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

        completedDeposits = (depositStats?['completed']?['count'] as int?) ?? 0;
        totalDepositAmount =
            (depositStats?['completed']?['totalAmount'] as num?)?.toDouble() ??
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

        print('Transaction stats updated successfully');
      } else {
        // Handle Stats API error response
        final statsMsg = statsResponse['message'] ??
            statsResponse['error'] ??
            'Failed to fetch transaction stats';
        print('Error fetching transaction stats: $statsMsg');
        // Maybe show a specific error for stats failure, or just log it
      }
    } catch (e) {
      print('Exception in getInfos (fetching profile/stats): $e');
      msg = context.translate('error_occurred');
      String title = context.translate('error');
      if (mounted) {
        showPopupMessage(context, title, msg);
      }
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false; // Hide spinner after all fetches attempt
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: context.translate('wallet'), // 'Portfeuille'
      inAsyncCall: showSpinner,
      child: RefreshIndicator(
        // Wrap with RefreshIndicator
        onRefresh: getInfos, // Call getInfos on pull to refresh
        child: SingleChildScrollView(
          // Add SingleChildScrollView
          physics:
              AlwaysScrollableScrollPhysics(), // Ensure scrollable even if content is small
          child: Container(
            margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
            padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 2 * fem, 15 * fem),
                  padding:
                      EdgeInsets.fromLTRB(0 * fem, 15 * fem, 0 * fem, 15 * fem),
                  width: 340 * fem,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffdae3ea)),
                    color: Color(0xfff9f9f9),
                    borderRadius: BorderRadius.circular(4 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.translate('my_balance'), // 'Mon solde'
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w500,
                          height: 1.6666666667 * ffem / fem,
                          color: Color(0xff6d7d8b),
                        ),
                      ),
                      Text(
                        '$balance FCFA',
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 20 * ffem,
                          fontWeight: FontWeight.w700,
                          height: 1.2175 * ffem / fem,
                          color: Color(0xff25313c),
                        ),
                      ),
                      Text(
                        context.translate('total_benefit', args: {
                          'benefice': benefice.toStringAsFixed(1)
                        }), // 'Benefice total $benefice Fcfa'
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 8 * ffem,
                          fontWeight: FontWeight.w400,
                          height: 2.5 * ffem / fem,
                          color: Color(0xff6d7d8b),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Transaction Stats Section ---
                Container(
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 2 * fem, 20 * fem),
                  padding: EdgeInsets.symmetric(
                      horizontal: 15 * fem, vertical: 10 * fem),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffdae3ea)),
                    color: Color(0xfff9f9f9),
                    borderRadius: BorderRadius.circular(4 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('transaction_summary'),
                        style: SafeGoogleFont(
                          'Montserrat',
                          fontSize: 14 * ffem,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff25313c),
                        ),
                      ),
                      SizedBox(height: 10 * fem),
                      _buildStatRow(
                          fem,
                          ffem,
                          context.translate('completed_deposits'),
                          '$completedDeposits (${totalDepositAmount.toStringAsFixed(0)} FCFA)'),
                      _buildStatRow(
                          fem,
                          ffem,
                          context.translate('pending_deposits'),
                          pendingDeposits.toString()),
                      SizedBox(height: 5 * fem),
                      _buildStatRow(
                          fem,
                          ffem,
                          context.translate('completed_withdrawals'),
                          '$completedWithdrawals (${totalWithdrawalAmount.toStringAsFixed(0)} FCFA)'),
                      _buildStatRow(
                          fem,
                          ffem,
                          context.translate('pending_withdrawals'),
                          pendingWithdrawals.toString()),
                    ],
                  ),
                ),
                // --- End Stats Section ---

                ReusableButton(
                  title: context.translate('withdraw'), // 'Retrait'
                  onPress: () {
                    print(momoNumber);
                    print(momoCor);
                    if (momoNumber == '' || momoCor == '') {
                      showPopupMessage(context, context.translate('error'),
                          context.translate('momo_not_set'));
                      return;
                    }
                    context.pushNamed(Retrait.id);
                  },
                ),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      showDragHandle: true,
                      isScrollControlled: true,
                      useSafeArea: true,
                      context: context,
                      builder: (context) {
                        return BottomHitory();
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    margin:
                        EdgeInsets.fromLTRB(2 * fem, 0 * fem, 0 * fem, 0 * fem),
                    padding: EdgeInsets.fromLTRB(
                        13 * fem, 13 * fem, 12 * fem, 12 * fem),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(7 * fem),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3f25313c),
                          offset: Offset(0 * fem, 0 * fem),
                          blurRadius: 2.1500000954 * fem,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.translate('history'), // 'Historique'
                          style: SafeGoogleFont(
                            'Montserrat',
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.25 * ffem / fem,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Container(
                          width: 40 * fem,
                          height: 40 * fem,
                          child: Image.asset(
                            'assets/design/images/chevrondowncirclefill.png',
                            width: 40 * fem,
                            height: 40 * fem,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(double fem, double ffem, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 12 * ffem,
            fontWeight: FontWeight.w400,
            height: 1.6666666667 * ffem / fem,
            color: Color(0xff6d7d8b),
          ),
        ),
        Text(
          value,
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 12 * ffem,
            fontWeight: FontWeight.w400,
            height: 1.6666666667 * ffem / fem,
            color: Color(0xff6d7d8b),
          ),
        ),
      ],
    );
  }
}
