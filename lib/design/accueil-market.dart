import 'package:flutter/material.dart';
// import 'package:snipper_frontend/components/pricingcard.dart';
import 'package:snipper_frontend/components/prodtpost.dart';
import 'package:snipper_frontend/components/textfield.dart';
// import 'package:snipper_frontend/utils.dart';

class Market extends StatelessWidget {
  const Market({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;
    return Container(
      margin: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
      padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextField(
            hintText: 'Recherchez un produit ou service',
            onChange: (val) {},
            searchMode: true,
          ),
          PrdtPost(
            image: 'assets/design/images/rectangle-2771.png',
            onContact: () {},
            title: 'Service de livraison',
          ),
          SizedBox(height: 40.0,),
          PrdtPost(
            image: 'assets/design/images/rectangle-2771-jJ1.png',
            onContact: () {},
            title: 'Tenis bleu blanc',
          ),
          SizedBox(height: 40.0,),
          PrdtPost(
            image: 'assets/design/images/rectangle-2771-bg.png',
            onContact: () {},
            title: 'Talon gris',
          ),
        ],
      ),
    );
  }
}
