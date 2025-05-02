import 'package:flutter/material.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

class PricingCard extends StatelessWidget {
  const PricingCard({
    super.key,

    /// 1 for basic, 2 for pro & 3 for gold
    /// 10 for classic subscription, 11 for targeted subscription
    required this.type,

    /// Called when user presses on "commander maintenant"
    required this.onCommand,
  });

  final int type;
  final Function() onCommand;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    String categ;
    String pointImage;
    String price;
    Color color;

    List<String> description = [];

    if (type == 0) {
      categ = context.translate('subscription');
      pointImage = 'assets/design/images/group-45809-oeR.png';
      price = '2000';
      color = Theme.of(context).colorScheme.primary;
      description.addAll(
        [
          context.translate('access_contacts_sheet'),
          context.translate('withdraw_money'),
          context.translate('whatsapp_group_access'),
          context.translate('trading_training'),
          context.translate('marketing_training'),
          context.translate('china_purchase_training'),
          context.translate('public_speaking_training'),
          context.translate('marketplace_access'),
        ],
      );
    } else if (type == 10) {
      categ = context.translate('classic_subscription');
      pointImage = 'assets/design/images/group-45809-oeR.png';
      price = '2000';
      color = Theme.of(context).colorScheme.primary;
      description.addAll(
        [
          context.translate('access_contacts_sheet'),
          context.translate('withdraw_money'),
          context.translate('whatsapp_group_access'),
          context.translate('trading_training'),
          context.translate('marketing_training'),
          context.translate('china_purchase_training'),
          context.translate('public_speaking_training'),
          context.translate('marketplace_access'),
        ],
      );
    } else if (type == 11) {
      categ = context.translate('targeted_subscription');
      pointImage = 'assets/design/images/group-45809-Dah.png';
      price = '5000';
      color = Theme.of(context).colorScheme.tertiary;
      description.addAll(
        [
          context.translate('access_contacts_sheet'),
          context.translate('targeted_contacts_access'),
          context.translate('withdraw_money'),
          context.translate('whatsapp_group_access'),
          context.translate('trading_training'),
          context.translate('marketing_training'),
          context.translate('china_purchase_training'),
          context.translate('public_speaking_training'),
          context.translate('marketplace_access'),
        ],
      );
    } else if (type == 1) {
      categ = context.translate('basic');
      pointImage = 'assets/design/images/group-45809-oeR.png';
      price = '2000';
      color = Theme.of(context).colorScheme.primary;
      description.addAll(
        [
          context.translate('whatsapp_promo_once'),
          context.translate('marketplace_access_3'),
        ],
      );
    } else if (type == 2) {
      categ = context.translate('pro');
      pointImage = 'assets/design/images/group-45809.png';
      price = '5000';
      color = Theme.of(context).colorScheme.secondary;
      description.addAll(
        [
          context.translate('whatsapp_promo_thrice'),
          context.translate('marketplace_access_6'),
        ],
      );
    } else {
      categ = context.translate('gold');
      pointImage = 'assets/design/images/group-45809-Dah.png';
      price = '10000';
      color = Theme.of(context).colorScheme.tertiary;
      description.addAll(
        [
          context.translate('whatsapp_promo_five'),
          context.translate('marketplace_access_10'),
          context.translate('facebook_promo'),
          context.translate('flyer_design'),
        ],
      );
    }

    final String priceQualifier = (type == 10 || type == 11)
        ? context.translate('for_life')
        : (type > 0 ? '/mo' : context.translate('for_life'));

    return Container(
      margin: EdgeInsets.fromLTRB(
        0 * fem,
        0 * fem,
        0 * fem,
        15 * fem,
      ),
      padding: EdgeInsets.fromLTRB(
        24 * fem,
        20 * fem,
        24 * fem,
        20 * fem,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffbbc8d4)),
        color: Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(24 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 0 * fem, 15 * fem),
            child: Text(
              categ,
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 12 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.3333333333 * ffem / fem,
                letterSpacing: 0.400000006 * fem,
                color: color,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(
              0 * fem,
              4 * fem,
              0 * fem,
              12 * fem,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      0 * fem,
                      0 * fem,
                      0 * fem,
                      0 * fem,
                    ),
                    child: Text(
                      '${price}F',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Montserrat',
                        fontSize: 36 * ffem,
                        fontWeight: FontWeight.w700,
                        height: 0.4444444444 * ffem / fem,
                        letterSpacing: 0.400000006 * fem,
                        color: color,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                    0 * fem,
                    0 * fem,
                    0 * fem,
                    0 * fem,
                  ),
                  child: Text(
                    priceQualifier,
                    textAlign: TextAlign.center,
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 12 * ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.3333333333 * ffem / fem,
                      letterSpacing: 0.400000006 * fem,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
            width: 283 * fem,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: description
                  .map(
                    (desc) => Container(
                      margin: EdgeInsets.fromLTRB(
                        0 * fem,
                        0 * fem,
                        0 * fem,
                        8 * fem,
                      ),
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                              0 * fem,
                              0 * fem,
                              21 * fem,
                              1 * fem,
                            ),
                            width: 13 * fem,
                            height: 13 * fem,
                            child: Image.asset(
                              pointImage,
                              width: 13 * fem,
                              height: 13 * fem,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              desc,
                              style: SafeGoogleFont(
                                'Montserrat',
                                fontSize: 10 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.6 * ffem / fem,
                                letterSpacing: 0.400000006 * fem,
                                color: Color(0xff6d7d8b),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ReusableButton(
            title: context.translate('order_now'),
            onPress: onCommand,
            mainColor: color,
          ),
        ],
      ),
    );
  }
}
