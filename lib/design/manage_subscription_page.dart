import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/pricingcard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/theme.dart';

class ManageSubscriptionPage extends StatefulWidget {
  static const id = 'manage_subscription_page';

  const ManageSubscriptionPage({super.key});

  @override
  State<ManageSubscriptionPage> createState() => _ManageSubscriptionPageState();
}

class _ManageSubscriptionPageState extends State<ManageSubscriptionPage> {
  bool showSpinner = false;
  late SharedPreferences prefs;
  final ApiService _apiService = ApiService();

  String? userName;
  String? userEmail;
  String? userAvatar;
  bool hasActiveSubscription = false;
  bool isCibleSubscribed = false;
  List<String> activeSubscriptionTypes =
      []; // To store names like 'CLASSIQUE', 'CIBLE'

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndSubscription();
  }

  Future<void> _loadUserProfileAndSubscription() async {
    setState(() {
      showSpinner = true;
    });
    prefs = await SharedPreferences.getInstance();
    try {
      final response = await _apiService.getUserProfile();
      if (mounted &&
          response.statusCode == 200 &&
          response.apiReportedSuccess) {
        final userData = response.body['data'] as Map<String, dynamic>;
        userName = userData['name'] as String?;
        userEmail = userData['email'] as String?;
        userAvatar = userData['avatar'] as String?;

        final List<dynamic> activeSubs =
            userData['activeSubscriptions'] as List<dynamic>? ?? [];
        activeSubscriptionTypes = activeSubs
            .map((sub) {
              // Assuming the subscription object has a 'planType' or similar field
              // Adjust based on your actual API response structure for active subscriptions
              if (sub is Map<String, dynamic> && sub.containsKey('planType')) {
                return sub['planType'].toString().toUpperCase();
              } else if (sub is String) {
                return sub
                    .toUpperCase(); // Fallback if it's just a list of strings
              }
              return ''; // Should not happen ideally
            })
            .where((type) => type.isNotEmpty)
            .toList();

        hasActiveSubscription = activeSubscriptionTypes.isNotEmpty;
        isCibleSubscribed = activeSubscriptionTypes.contains('CIBLE');

        // Save to prefs for consistency, though this page primarily uses state
        await prefs.setBool('isSubscribed', hasActiveSubscription);
        await prefs.setStringList(
            'activeSubscriptions', activeSubscriptionTypes);
      } else {
        if (mounted) {
          showPopupMessage(
              context, context.translate('error'), response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        showPopupMessage(context, context.translate('error'),
            context.translate('error_occurred') + ': ${e.toString()}');
      }
      print('Error loading profile/subscription: $e');
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  Future<void> _initiateUpgradeToCible() async {
    setState(() {
      showSpinner = true;
    });
    try {
      final response = await _apiService.upgradeSubscription();

      final msg = response.message;

      if (response.apiReportedSuccess) {
        final responseData = response.body['data'];
        final paymentDetails = responseData?['paymentDetails'];
        final dynamic rawSessionId = paymentDetails?['sessionId'];

        if (rawSessionId is String && rawSessionId.isNotEmpty) {
          final String sessionId = rawSessionId;
          final paymentUrl = _apiService.generatePaymentUrl(sessionId);
          launchURL(paymentUrl);
          if (mounted)
            showPopupMessage(
                context, context.translate('redirecting_to_payment'), '');
          // After payment, page should refresh or user might need to pull-to-refresh
          _loadUserProfileAndSubscription(); // Refresh data
        } else {
          if (mounted)
            showPopupMessage(context, context.translate('error'),
                context.translate('error_initiating_payment'));
        }
      } else {
        if (mounted) showPopupMessage(context, context.translate('error'), msg);
      }
    } catch (e) {
      if (mounted)
        showPopupMessage(context, context.translate('error'),
            context.translate('error_occurred'));
      print('Error upgrading to Cible: $e');
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  Future<void> logoutUser() async {
    final avatar = prefs.getString('avatar');

    setState(() {
      showSpinner = true;
    });

    try {
      final response = await _apiService.logoutUser();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await deleteFile(avatar ?? '');
        await prefs.clear();

        String msg = response.message;
        String title = context.translate('logout');
        showPopupMessage(context, title, msg);

        if (mounted) context.go('/');
      } else {
        String errorMsg = response.message;
        showPopupMessage(context, context.translate('error'), errorMsg);
        print('API Error logoutUser: ${response.statusCode} - $errorMsg');
      }
    } catch (e) {
      print('Exception in logoutUser: $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.translate('manage_subscription')),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
            color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: RefreshIndicator(
          onRefresh: _loadUserProfileAndSubscription,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSpinner &&
                    !hasActiveSubscription &&
                    !isCibleSubscribed) // Initial loading state
                  Center(child: CircularProgressIndicator()),
                if (!showSpinner && !hasActiveSubscription)
                  _buildNoSubscriptionView(),
                if (!showSpinner && hasActiveSubscription)
                  _buildSubscriptionDetailsView(),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          showSpinner = true;
                        });

                        await logoutUser();

                        setState(() {
                          showSpinner = false;
                        });

                        String msg =
                            context.translate('logged_out_successfully');
                        String title = context.translate('logout');
                        showPopupMessage(context, title, msg);
                      } catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        String msg = context.translate('error_occurred');
                        String title = context.translate('error');
                        showPopupMessage(context, title, msg);
                        print(e);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      context.translate('logout'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildSubscriptionDetailsView() {
    if (isCibleSubscribed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('current_plan'),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue),
          ),
          SizedBox(height: 8),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('targeted_subscription'), // CIBLE
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          context.translate('highest_tier_active'),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (activeSubscriptionTypes.contains('CLASSIQUE')) {
      // User has CLASSIQUE, offer CIBLE upgrade
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('current_plan'),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue),
          ),
          SizedBox(height: 8),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: AppTheme.primaryBlue, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context
                              .translate('classic_subscription'), // CLASSIQUE
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          context.translate('upgrade_to_unlock_more'),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            context.translate('upgrade_plan'),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.tertiaryOrange),
          ),
          SizedBox(height: 16),
          PricingCard(
            type: 11, // CIBLE plan type
            onCommand: _initiateUpgradeToCible,
            buttonTitle: context.translate('upgrade_now'),
            buttonColor:
                AppTheme.tertiaryOrange, // Or another color like Colors.green
          ),
        ],
      );
    }
    // Should not be reached if hasActiveSubscription is true and not CIBLE or CLASSIQUE
    // but as a fallback:
    return _buildNoSubscriptionView();
  }

  Widget _buildNoSubscriptionView() {
    // This view is if somehow user lands here with no active sub.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subscriptions_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 24),
          Text(
            context.translate('no_active_subscription'),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            context.translate('explore_subscription_plans_to_unlock'),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            icon: Icon(Icons.payment),
            label: Text(context.translate('subscribe_now')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              context
                  .goNamed('subscrition'); // Go to the main subscription page
            },
          ),
        ],
      ),
    );
  }
}
