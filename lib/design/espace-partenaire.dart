import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/customDropdown.dart';
import 'package:snipper_frontend/design/historique-transaction-bottom-sheet.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:snipper_frontend/api_service.dart';

class EspacePartenaire extends StatefulWidget {
  static const id = 'espace-partenaire';

  @override
  State<EspacePartenaire> createState() => _EspacePartenaireState();
}

class _EspacePartenaireState extends State<EspacePartenaire> {
  late SharedPreferences prefs;

  String pack = '';
  double amount = 0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadPartnerData();
  }

  Future<void> _loadPartnerData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    prefs = await SharedPreferences.getInstance();

    try {
      final response = await _apiService.getPartnerDetails();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final fetchedPack = data['pack'] as String? ?? '';
        final fetchedAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;

        if (mounted) {
          setState(() {
            pack = fetchedPack;
            amount = fetchedAmount;
          });
          await prefs.setString('partnerPack', fetchedPack);
          await prefs.setDouble('partnerAmount', fetchedAmount);
        }
      } else {
        final msg = response['message'] ??
            response['error'] ??
            context.translate('error_loading_partner_data');
        if (mounted) {
          setState(() {
            errorMessage = msg;
            pack = prefs.getString('partnerPack') ?? '';
            amount = prefs.getDouble('partnerAmount') ?? 0;
          });
        }
      }
    } catch (e) {
      print("Error loading partner data: $e");
      if (mounted) {
        setState(() {
          errorMessage = context.translate('error_occurred');
          pack = prefs.getString('partnerPack') ?? '';
          amount = prefs.getDouble('partnerAmount') ?? 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    final type = pack == 'gold' ? 2 : 1;
    bool isGold = pack == 'gold';
    final color = isGold ? gold : silver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.translate('partner_sbc'),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadPartnerData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(24 * fem),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Text(
                          context.translate('partner_dashboard'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        SizedBox(height: 24 * fem),
                        BonusCard(type: type, amount: amount.toInt()),
                        SizedBox(height: 16 * fem),
                        BonusCard(
                          type: type,
                          amount: amount.toInt(),
                          isDevelopment: true,
                        ),
                        SizedBox(height: 24 * fem),
                        HistoryDropdown(
                          title: context.translate('history'),
                          color: color,
                          onPressed: () {
                            showModalBottomSheet(
                              showDragHandle: true,
                              isScrollControlled: true,
                              useSafeArea: true,
                              context: context,
                              builder: (context) {
                                return BottomHitory(type: 'partner');
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class BonusCard extends StatelessWidget {
  const BonusCard({
    super.key,
    required this.type,
    required this.amount,
    this.isDevelopment = false,
  });

  /// 1 = SILVER, 2 = GOLD
  final int type;

  /// Amount of bonus
  final int amount;

  /// BONUS DE DEVELOPMENT
  final bool isDevelopment;

  @override
  Widget build(BuildContext context) {
    final color = type == 1 ? silver : gold;
    final bg = type == 1 ? Colors.white : const Color(0xff6f7377);
    final textColor = type == 1 ? const Color(0xff6f7377) : Colors.white;
    final perc = type == 1 ? 0.18 : 0.30;
    final text = type == 1
        ? context.translate('silver_18')
        : context.translate('gold_30');
    final subTitle = isDevelopment
        ? context.translate('development_bonus')
        : context.translate('network_benefit');

    final amtDisp = isDevelopment ? perc * amount : amount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isDevelopment)
            Text.rich(
              TextSpan(
                text: 'PACK ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: textColor,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
          Text(
            '${formatNumber(amtDisp)} FCFA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
          SizedBox(height: 20),
          Text(
            subTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String formatNumber(num number) {
    String numStr = number.toString();
    String formattedNumber = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      count++;
      formattedNumber = numStr[i] + formattedNumber;
      if (count == 3 && i != 0) {
        formattedNumber = ',' + formattedNumber;
        count = 0;
      }
    }

    return formattedNumber;
  }
}
