import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/imagecard.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization

class PrdtPost extends StatelessWidget {
  const PrdtPost({
    super.key,
    required this.image,
    required this.onContact,
    required this.title,
    required this.price,
    required this.prdtId,
    required this.sellerId,
    this.rating,
  });

  final String prdtId;
  final String sellerId;

  final String image;
  final String title;
  final int price;
  final Function() onContact;
  final Widget? rating;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      padding: EdgeInsets.fromLTRB(20 * fem, 0 * fem, 20 * fem, 0 * fem),
      width: 340 * fem,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageCard(
                    network: true,
                    image: image,
                    rating: rating,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 220,
                          child: Text(
                            title,
                            textAlign: TextAlign.left,
                            style: SafeGoogleFont(
                              'Montserrat',
                              fontSize: 20 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1 * ffem / fem,
                              color: Color(0xff25313c),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Container(
                          child: Text(
                            price == 0
                                ? context.translate('free')
                                : '${formatAmount(price)} FCFA',
                            textAlign: TextAlign.left,
                            style: SafeGoogleFont(
                              'Mulish',
                              fontSize: 17 * ffem,
                              fontWeight: FontWeight.w800,
                              height: 1.255 * ffem / fem,
                              color: Color(0xfff49101),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ReusableButton(
                  mh: 10,
                  title: context.translate('contact_now'),
                  onPress: onContact,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 10 * fem, 13 * fem),
                  child: TextButton.icon(
                    onPressed: () {
                      final shareLink =
                          'https://sniperbuisnesscenter.com/?sellerId=$sellerId&prdtId=$prdtId';

                      Share.share(shareLink);
                    },
                    label: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
