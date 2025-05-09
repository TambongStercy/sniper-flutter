import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/pricingcard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import the extension

// ignore: must_be_immutable
class Subscrition extends StatefulWidget {
  Subscrition({super.key});

  static const id = 'subscrition';

  @override
  State<Subscrition> createState() => _SubscritionState();
}

class _SubscritionState extends State<Subscrition> {
  bool showSpinner = false;

  String? id;
  String? email;
  String? name;
  String? avatar;
  String? token;
  bool isSubscribed = false;
  bool isPartner = false;

  late SharedPreferences prefs;
  final ApiService _apiService = ApiService();

  Future<void> getInfos() async {
    setState(() {
      showSpinner = true;
    });
    String msg = '';
    await initSharedPref();

    try {
      final response =
          await _apiService.getUserProfile(); // Already fetches profile

      msg =
          response['message'] ?? response['error'] ?? 'Error fetching profile';

      if (response['success'] == true && response['data'] != null) {
        final userProfile = response['data'] as Map<String, dynamic>;

        // Extract data using the correct keys from the profile response
        final name = userProfile['name'] as String?;
        final region = userProfile['region'] as String?;
        final phone = userProfile['phoneNumber']?.toString();
        final userCode = userProfile['referralCode'] as String?;
        final balance = (userProfile['balance'] as num?)?.toDouble();
        final totalBenefits = (userProfile['totalBenefits'] as num?)
            ?.toDouble(); // Use totalBenefits
        final momo = userProfile['momoNumber']?.toString();
        final momoCorrespondent = userProfile['momoOperator'] as String?;
        final List<dynamic> activeSubscriptions =
            userProfile['activeSubscriptions'] as List<dynamic>? ?? [];
        final fetchedAvatar = userProfile['avatar'] as String?;

        // Update local state
        this.name = name ?? this.name;
        this.isSubscribed = activeSubscriptions.isNotEmpty;
        this.avatar = fetchedAvatar ?? this.avatar;
        // Partner status logic removed as it's not in this response

        // Update SharedPreferences with fresh data
        prefs = await SharedPreferences.getInstance();
        if (name != null) prefs.setString('name', name);
        if (region != null) prefs.setString('region', region);
        if (phone != null) prefs.setString('phone', phone);
        if (userCode != null) prefs.setString('code', userCode);
        if (balance != null) prefs.setDouble('balance', balance);
        if (totalBenefits != null)
          prefs.setDouble(
              'benefit', totalBenefits); // Save totalBenefits as benefit
        if (momo != null) prefs.setString('momo', momo);
        if (momoCorrespondent != null)
          prefs.setString('momoCorrespondent', momoCorrespondent);
        if (fetchedAvatar != null) prefs.setString('avatar', fetchedAvatar);
        prefs.setBool('isSubscribed', this.isSubscribed);
        prefs.setStringList('activeSubscriptions',
            activeSubscriptions.map((s) => s.toString()).toList());

        if (this.isSubscribed) {
          if (mounted) context.go('/');
        }
      } else {
        print('API Error getInfos: ${response['statusCode']} - $msg');
        showPopupMessage(
            context,
            context.translate('error'),
            msg.isNotEmpty
                ? msg
                : context.translate('failed_to_load_user_data'));
      }
    } catch (e) {
      print('Exception in getInfos: $e');
      String title = context.translate('error');
      showPopupMessage(context, title,
          context.translate('error_occurred') + ': ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    () async {
      try {
        await getInfos();
        showSpinner = false;
        refreshPage();
      } catch (e) {
        print(e);
        showSpinner = false;
        refreshPage();
      }
    }();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    id = prefs.getString('id') ?? '';
    token = prefs.getString('token') ?? '';
    email = prefs.getString('email') ?? '';
    name = prefs.getString('name') ?? '';
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  Future<void> subscribe(int planCode, String amount) async {
    String planTypeString;
    switch (planCode) {
      case 10:
        planTypeString = 'CLASSIQUE';
        break;
      case 11:
        planTypeString = 'CIBLE';
        break;
      default:
        print('Unknown plan code: $planCode');
        showPopupMessage(context, context.translate('error'),
            context.translate('invalid_plan_selected'));
        return;
    }

    setState(() {
      showSpinner = true;
    });

    try {
      final response = await _apiService.purchaseSubscription(planTypeString);

      final msg = response['message'] ?? response['error'] ?? 'Unknown error';

      if (response['success'] == true) {
        final responseData = response['data'];
        final paymentDetails = responseData['paymentDetails'];
        final dynamic rawSessionId =
            paymentDetails['sessionId']; // Get potential sessionId
        print(rawSessionId);

        // Check if sessionId is valid String before proceeding
        if (rawSessionId is String && rawSessionId.isNotEmpty) {
          final String sessionId = rawSessionId; // Cast to String
          final paymentLink = responseData?['paymentDetails']?['paymentLink'] ??
              responseData?['paymentLink']; // Existing logic for paymentLink

          // Now it's safe to generate the URL
          final paymentUrl = _apiService.generatePaymentUrl(sessionId);
          launchURL(paymentUrl);
          showPopupMessage(
              context, context.translate('redirecting_to_payment'), '');
        } else {
          // Handle missing or invalid sessionId
          print(
              "Error: Missing or invalid sessionId in subscription response: $rawSessionId");
          String title = context.translate('error');
          showPopupMessage(
              context,
              title,
              context.translate(
                      'error_initiating_payment') // Add new translation key if needed
                  ??
                  'Error initiating payment session. Session ID missing.');
        }
      } else {
        String title = context.translate('error');
        showPopupMessage(context, title, msg);
      }
    } catch (e) {
      print('Error initiating subscription: $e');
      String title = context.translate('error');
      showPopupMessage(context, title, context.translate('error_occurred'));
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

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        await deleteFile(avatar ?? '');
        await prefs.clear();

        String msg =
            response['message'] ?? context.translate('logged_out_successfully');
        String title = context.translate('logout');
        showPopupMessage(context, title, msg);

        if (mounted) context.go('/');
      } else {
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('logout_failed');
        showPopupMessage(context, context.translate('error'), errorMsg);
        print('API Error logoutUser: ${response['statusCode']} - $errorMsg');
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
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/design/images/logo.png',
          height: 50,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: getInfos,
        child: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),

                  // Header
                  Text(
                    'Sniper Business Center',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 24),

                  Text(
                    context.translate('subscription'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xfff49101),
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    context.translate('choose_subscription_plan'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Subscription plans
                  PricingCard(
                    type: 10,
                    onCommand: () {
                      subscribe(10, '2070');
                    },
                  ),

                  SizedBox(height: 16),

                  PricingCard(
                    type: 11,
                    onCommand: () {
                      subscribe(11, '5000');
                    },
                  ),

                  SizedBox(height: 40),

                  // Logout button
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
      ),
    );
  }

  void refreshPage() {
    if (mounted) setState(() {});
  }
}
