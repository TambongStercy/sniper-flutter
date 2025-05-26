import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

class SponsorInfoPage extends StatefulWidget {
  static const String id = 'sponsor_info_page';

  const SponsorInfoPage({super.key});

  @override
  State<SponsorInfoPage> createState() => _SponsorInfoPageState();
}

class _SponsorInfoPageState extends State<SponsorInfoPage> {
  final ApiService _apiService = ApiService();
  late SharedPreferences prefs;
  bool showSpinner = true;
  Map<String, dynamic>? sponsorData;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSponsorInfo();
  }

  Future<void> _loadSponsorInfo() async {
    if (!mounted) return;

    try {
      final response = await _apiService.getMyAffiliator();

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.apiReportedSuccess &&
          response.statusCode < 300 &&
          response.body['data'] != null) {
        setState(() {
          sponsorData = response.body['data'] as Map<String, dynamic>;
          showSpinner = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          showSpinner = false;
        });
      }
    } catch (e) {
      print('Error loading sponsor info: $e');
      if (mounted) {
        setState(() {
          errorMessage = context.translate('error_occurred');
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

    return SimpleScaffold(
      title: context.translate('sponsor_info_title'), // Need translation
      inAsyncCall: showSpinner,
      child: Padding(
        padding: EdgeInsets.all(16.0 * fem), // Adjusted padding
        child: Center(
          child: _buildContent(fem, ffem),
        ),
      ),
    );
  }

  Widget _buildContent(double fem, double ffem) {
    if (showSpinner) {
      return CircularProgressIndicator();
    }

    if (errorMessage.isNotEmpty) {
      return Text(
        errorMessage,
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 16 * ffem,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.error,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (sponsorData == null) {
      // This case should ideally be covered by errorMessage, but as a fallback
      return Text(
        context.translate('sponsor_not_found'), // Need translation
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 16 * ffem,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      );
    }

    final sponsorName = sponsorData!['name'] as String? ?? 'N/A';
    final sponsorAvatar = sponsorData!['avatarId'] as String? ?? '';
    final sponsorPhone = sponsorData!['phoneNumber']
        as String?; // Assuming phoneNumber is available
    final sponsorRegion = sponsorData!['region'] as String?;
    final sponsorCountry = sponsorData!['country'] as String?;
    final sponsorEmail =
        sponsorData!['email'] as String?; // Added email extraction

    return Card(
      // Wrap content in a Card
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0 * fem),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0 * fem), // Padding inside the card
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make card size to content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60 * fem,
              backgroundImage: profileImage(sponsorAvatar),
              backgroundColor: Colors.grey.shade300,
            ),
            SizedBox(height: 20 * fem),
            Text(
              sponsorName,
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 24 * ffem, // Slightly larger name
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).colorScheme.primary, // Use primary color
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15 * fem), // Adjusted spacing
            // Display Region, Country, Email
            if (sponsorRegion != null && sponsorRegion.isNotEmpty)
              _buildInfoRow(fem, ffem, Icons.location_city,
                  context.translate('region'), sponsorRegion),
            if (sponsorCountry != null && sponsorCountry.isNotEmpty)
              _buildInfoRow(fem, ffem, Icons.public,
                  context.translate('country'), sponsorCountry),
            if (sponsorEmail != null && sponsorEmail.isNotEmpty)
              _buildInfoRow(fem, ffem, Icons.email_outlined,
                  context.translate('email'), sponsorEmail),

            SizedBox(height: 30 * fem), // Increased spacing before button
            if (sponsorPhone != null && sponsorPhone.isNotEmpty)
              ElevatedButton.icon(
                icon: Icon(Icons.chat_bubble), // Changed to filled chat icon
                label: Text(context
                    .translate('contact_sponsor_whatsapp')), // Need translation
                onPressed: () {
                  // Ensure name is not null or empty before sending
                  final nameToSend = sponsorName != 'N/A'
                      ? sponsorName
                      : context.translate(
                          'sponsor'); // Need translation for 'sponsor'
                  sendWhatsAppMessage(
                    context,
                    nameToSend,
                    sponsorPhone,
                    messageBody: context.translate('hello'),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary, // Button color
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onPrimary, // Text/icon color
                    padding: EdgeInsets.symmetric(
                        horizontal: 24 * fem, vertical: 12 * fem),
                    textStyle: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 16 * ffem,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      // Rounded corners
                      borderRadius: BorderRadius.circular(8.0 * fem),
                    )),
              ),
            // Add more sponsor details here if needed (e.g., email, referral code)
            // Consider privacy implications before displaying too much contact info.
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      double fem, double ffem, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 5.0 * fem), // Increased vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to start
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon,
              size: 20 * ffem,
              color:
                  Theme.of(context).colorScheme.secondary), // Use theme color
          SizedBox(width: 12 * fem), // Increased spacing
          Text(
            '$label: ',
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 15 * ffem, // Slightly larger label
              fontWeight: FontWeight.w600, // Bolder label
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant, // Subtle color
            ),
          ),
          Expanded(
            // Allow value to expand
            child: Text(
              value,
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 15 * ffem, // Match label size
                fontWeight: FontWeight.w400, // Normal weight for value
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.left, // Align value text
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
