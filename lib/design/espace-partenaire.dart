import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/customDropdown.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/design/historique-transaction-bottom-sheet.dart';
import 'package:snipper_frontend/utils.dart';

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


  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    pack = prefs.getString('partnerPack') ?? '';
    amount = prefs.getDouble('partnerAmount') ?? 0;
    transactions = await getPartnerTrans();
  }


  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    final type = 1;
    bool isGold = pack == 'gold' ? true : false;
    final color = isGold ? gold : silver;

    return SimpleScaffold(
      appBarColor: color,
      // appBarColor: Color(0xffFFD700),
      title: 'Partenaire SBC',
      child: Container(
        padding: EdgeInsets.fromLTRB(27 * fem, 25 * fem, 23 * fem, 25 * fem),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BonusCard(type: type, amount: amount.toInt()),
            SizedBox(height: 15),
            BonusCard(
              type: type,
              amount: amount.toInt(),
              isDevelopment: true,
            ),
            SizedBox(height: 15),
            HistoryDropdown(
              title: 'Historique',
              color: color,
              onPressed: () {
                showModalBottomSheet(
                  showDragHandle: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  context: context,
                  builder: (context) {
                    return BottomHitory(
                      transactions: transactions,
                    );
                  },
                );
              },
            ),
          ],
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
    final bg = type == 1 ? Color(0xfffcfcfc) : Color(0xff6f7377);
    final textColor = type == 1 ? Color(0xff6f7377) : Color(0xfffcfcfc);
    final perc = type == 1 ? 0.18 : 0.30;
    final text = type == 1 ? 'SILVER (18%)' : 'GOLD (30%)';
    final subTitle =
        isDevelopment ? 'Bonus de Development' : 'Benefice dans mon resaux';

    final amtDisp = isDevelopment ? perc * amount : amount;

    return Container(
      margin: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        15,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        20,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffbbc8d4)),
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0x3f25313c),
            blurRadius: 2.9,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isDevelopment)
            Text.rich(
              TextSpan(
                text: 'PACK ', // default style
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3333333333,
                  letterSpacing: 0.400000006,
                  color: textColor,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: text,
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.3333333333,
                      letterSpacing: 0.400000006,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          // if(!isDevelopment)
          SizedBox(height: 20),
          Text(
            '${formatNumber(amtDisp)} FCFA',
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 0.4444444444,
              letterSpacing: 0.400000006,
              color: color,
            ),
          ),
          SizedBox(height: 30),
          Text(
            subTitle,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3333333333,
              letterSpacing: 0.400000006,
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
