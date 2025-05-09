import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snipper_frontend/components/pricingcard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

class Publicite extends StatelessWidget {
  const Publicite({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(24 * fem),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 32 * fem),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 24 * fem),
                    child: Text(
                      context.translate('boost_visibility'),
                      style: TextStyle(
                        fontSize: 24 * ffem,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    context.translate('advertisement_pack'),
                    style: TextStyle(
                      fontSize: 18 * ffem,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            PricingCard(
              type: 1,
              onCommand: () {
                context.pushNamed('pricing_details', extra: 1);
              },
            ),
            SizedBox(height: 16 * fem),
            PricingCard(
              type: 2,
              onCommand: () {
                context.pushNamed('pricing_details', extra: 2);
              },
            ),
            SizedBox(height: 16 * fem),
            PricingCard(
              type: 3,
              onCommand: () {
                context.pushNamed('pricing_details', extra: 3);
              },
            ),
            SizedBox(height: 32 * fem),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('active_pack'),
                  style: TextStyle(
                    fontSize: 18 * ffem,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16 * fem),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20 * fem),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12 * fem),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      context.translate('no_active_pack'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16 * ffem,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
