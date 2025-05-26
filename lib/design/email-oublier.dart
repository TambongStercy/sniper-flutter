import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/new-password.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Ensure localization is set up
import 'package:snipper_frontend/api_service.dart'; // Import ApiService
import 'package:snipper_frontend/theme.dart';

class EmailOublie extends StatefulWidget {
  static const id = 'emailOublie';

  const EmailOublie({super.key});

  @override
  State<EmailOublie> createState() => _EmailOublieState();
}

class _EmailOublieState extends State<EmailOublie> {
  String email = '';
  final ApiService apiService = ApiService(); // Instantiate ApiService

  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> sendFOTP() async {
    if (email.trim().isEmpty) {
      String msg = context.translate('fill_info'); // Translated
      String title = context.translate('incomplete_info'); // Translated
      showPopupMessage(context, title, msg);
      return;
    }
    // Optional: Add domain validation here too if desired
    // if (!isValidEmailDomain(email.trim())) { ... }

    setState(() {
      showSpinner = true;
    });

    try {
      final response = await apiService.requestPasswordResetOtp(email.trim());
      final msg = response.message;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String title = context.translate('code_sent'); // Translated
        showPopupMessage(context, title,
            msg.isNotEmpty ? msg : context.translate('otp_sent_instructions'));

        // Navigate to NewPassword screen, passing the email
        context.pushNamed(
          NewPassword.id,
          extra: email.trim(),
        );
      } else {
        String title = context.translate('something_wrong'); // Translated
        showPopupMessage(context, title,
            msg.isNotEmpty ? msg : context.translate('otp_request_failed'));
        print(
            'API Error sendFOTP (EmailOublie): ${response.statusCode} - $msg');
      }
    } catch (e) {
      print('Exception in sendFOTP (EmailOublie): $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
    } finally {
      if (mounted)
        setState(() {
          showSpinner = false;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Image.asset(
            'assets/design/images/logo.png',
            height: 50,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('forgot_password'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.translate('enter_email'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  fieldType: CustomFieldType.email,
                  hintText: context.translate('email_hint'),
                  value: email,
                  onChange: (val) {
                    setState(() {
                      email = val;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sendFOTP,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        context.translate('send_otp'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.goNamed(Inscription.id);
                    },
                    child: Text(
                      context.translate('no_account'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
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

  Container _fieldTitle(double fem, double ffem, String title) {
    return Container(
      margin: EdgeInsets.fromLTRB(49 * fem, 0 * fem, 49 * fem, 5 * fem),
      child: Text(
        title,
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 12 * ffem,
          fontWeight: FontWeight.w500,
          height: 1.3333333333 * ffem / fem,
          letterSpacing: 0.400000006 * fem,
          color: const Color(0xff6d7d8b),
        ),
      ),
    );
  }

  void popUntilAndPush(BuildContext context) {
    context.go('/');
  }
}
