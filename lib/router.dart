import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/design/accueil.dart';
import 'package:snipper_frontend/design/add-product.dart';
import 'package:snipper_frontend/design/affiliation-page-filleuls-details.dart';
import 'package:snipper_frontend/design/affiliation-page.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/contact-update.dart';
import 'package:snipper_frontend/design/email-oublier.dart';
import 'package:snipper_frontend/design/espace-partenaire.dart';
import 'package:snipper_frontend/design/inscription.dart';
import 'package:snipper_frontend/design/manage_subscription_page.dart';
import 'package:snipper_frontend/design/modify-email.dart';
import 'package:snipper_frontend/design/modify-product.dart';
import 'package:snipper_frontend/design/new-email.dart';
import 'package:snipper_frontend/design/new-password.dart';
import 'package:snipper_frontend/design/notifications.dart';
import 'package:snipper_frontend/design/portfeuille.dart';
import 'package:snipper_frontend/design/produit-page.dart';
import 'package:snipper_frontend/design/profile-info.dart';
import 'package:snipper_frontend/design/profile-modify.dart';
import 'package:snipper_frontend/design/retrait.dart';
import 'package:snipper_frontend/design/splash1.dart';
import 'package:snipper_frontend/design/sponsor_info_page.dart';
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/design/verify_registration.dart';
import 'package:snipper_frontend/design/your-products.dart';

class AppRouter {
  static late SharedPreferences prefs;

  static String? token = '';
  static bool isSubscribed = false;

  static Future<void> refreshPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  static bool canAccessRoute(String route) {
    // Only allow access to these routes without subscription
    return [
      '/${Connexion.id}',
      '/${Inscription.id}',
      '/${PpUpload.id}',
      '/${Subscrition.id}',
      '/${NewPassword.id}',
      '/${EmailOublie.id}',
      '/${NewEmail.id}',
      '/${VerifyRegistration.id}',
      '/',
    ].contains(route);
  }

  static GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      print('Navigating to: ${state.topRoute!.path}');

      await refreshPref();

      final isLoggedIn = token != null && token!.isNotEmpty;

      // If the user is not logged in and tries to access a restricted page, redirect to login
      if (!isLoggedIn && !canAccessRoute(state.topRoute!.path)) {
        return '/';
      }

      // If the user is logged in but not subscribed, restrict access to subscription page
      if (isLoggedIn && !isSubscribed) {
        return '/${Subscrition.id}';
      }

      if (isLoggedIn &&
          isSubscribed &&
          state.topRoute!.path == '/${Subscrition.id}') {
        return '/';
      }

      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final String? affiliationCode =
              state.uri.queryParametersAll['affiliationCode']?[0];
          final String? sellerId = state.uri.queryParametersAll['sellerId']?[0];
          final String? prdtId = state.uri.queryParametersAll['prdtId']?[0];

          final isSub = prefs.getBool('isSubscribed');

          return (token != null && token!.isNotEmpty && isSub != null && isSub)
              ? Accueil(sellerId: sellerId, prdtId: prdtId)
              : Scene(affiliationCode: affiliationCode);
        },
      ),
      GoRoute(
        path: '/${Inscription.id}',
        name: Inscription.id,
        builder: (context, state) {
          final String? affiliationCode =
              state.uri.queryParameters['affiliationCode'];
          return Inscription(affiliationCode: affiliationCode);
        },
      ),
      GoRoute(
        path: '/${ProduitPage.id}',
        name: ProduitPage.id,
        builder: (context, state) {
          // Decode the JSON string back to a Map
          final prdtAndUser = state.extra as Map<String, dynamic>;

          return ProduitPage(
            productId: prdtAndUser['productId'] as String,
            sellerId: prdtAndUser['sellerId'] as String,
          );
        },
      ),
      GoRoute(
        path: '/${SponsorInfoPage.id}',
        name: SponsorInfoPage.id,
        builder: (context, state) => SponsorInfoPage(),
      ),
      GoRoute(
        path: '/${VerifyRegistration.id}',
        name: VerifyRegistration.id,
        builder: (context, state) {
          final extraData = state.extra;

          if (extraData is Map<String, dynamic> &&
              extraData.containsKey('email') &&
              extraData.containsKey('userId')) {
            final email = extraData['email'] as String?;
            final userId = extraData['userId'] as String?;

            if (email != null &&
                email.isNotEmpty &&
                userId != null &&
                userId.isNotEmpty) {
              return VerifyRegistration(email: email, userId: userId);
            }
          }

          print("Error: Invalid or missing data for VerifyRegistration route.");
          return Scaffold(
            body: Center(
              child: Text(
                'Error: Could not verify registration. Missing required information.',
              ),
            ),
          );
        },
      ),
      GoRoute(
          path: '/${Connexion.id}',
          name: Connexion.id,
          builder: (context, state) => Connexion()),
      GoRoute(
        path: '/${Affiliation.id}',
        name: Affiliation.id,
        builder: (context, state) => Affiliation(),
      ),
      GoRoute(
        path: '/${ManageSubscriptionPage.id}',
        name: ManageSubscriptionPage.id,
        builder: (context, state) => ManageSubscriptionPage(),
      ),
      GoRoute(
        path: '/${AjouterProduit.id}',
        name: AjouterProduit.id,
        builder: (context, state) => AjouterProduit(),
      ),
      GoRoute(
        path: '/${Notifications.id}',
        name: Notifications.id,
        builder: (context, state) => Notifications(),
      ),
      GoRoute(
        path: '/${EspacePartenaire.id}',
        name: EspacePartenaire.id,
        builder: (context, state) => EspacePartenaire(),
      ),
      GoRoute(
        path: '/${Profile.id}',
        name: Profile.id,
        builder: (context, state) => Profile(),
      ),
      GoRoute(
        path: '/${ProfileMod.id}',
        name: ProfileMod.id,
        builder: (context, state) => ProfileMod(),
      ),
      GoRoute(
        path: '/${Retrait.id}',
        name: Retrait.id,
        builder: (context, state) => Retrait(),
      ),
      GoRoute(
        path: '/${Wallet.id}',
        name: Wallet.id,
        builder: (context, state) => Wallet(),
      ),
      GoRoute(
        path: '/${ModifyEmail.id}',
        name: ModifyEmail.id,
        builder: (context, state) => ModifyEmail(),
      ),
      GoRoute(
        path: '/${EmailOublie.id}',
        name: EmailOublie.id,
        builder: (context, state) => EmailOublie(),
      ),
      GoRoute(
        path: '/${YourProducts.id}',
        name: YourProducts.id,
        builder: (context, state) => YourProducts(),
      ),
      GoRoute(
        path: '/${PpUpload.id}',
        name: PpUpload.id,
        builder: (context, state) => PpUpload(),
      ),
      GoRoute(
        path: '/${Filleuls.id}',
        name: Filleuls.id, // Route name defined in Filleuls as a static const
        builder: (context, state) {
          // Retrieve the email from the extra parameter
          final String email = state.extra as String;
          return Filleuls(email: email);
        },
      ),
      GoRoute(
        path: '/${NewEmail.id}',
        name: NewEmail.id, // Route name defined in NewEmail as a static const
        builder: (context, state) {
          // Retrieve the email from the extra parameter
          final String email = state.extra as String;
          return NewEmail(email: email);
        },
      ),
      GoRoute(
        path: '/${ModifyProduct.id}',
        name: ModifyProduct
            .id, // Route name defined in ModifyProduct as a static const
        builder: (context, state) {
          // Retrieve the email from the extra parameter
          final Map<String, dynamic> prdt = state.extra as Map<String, dynamic>;
          return ModifyProduct(product: prdt);
        },
      ),
      GoRoute(
        path: '/${NewPassword.id}',
        name: NewPassword
            .id, // Route name defined in NewPassword as a static const
        builder: (context, state) {
          // Retrieve the email from the extra parameter
          final String email = state.extra as String;
          return NewPassword(email: email);
        },
      ),
      GoRoute(
        path: '/${Subscrition.id}',
        name: Subscrition.id,
        builder: (context, state) => Subscrition(),
      ),
      GoRoute(
        path: '/${ContactUpdate.id}',
        name: ContactUpdate.id,
        builder: (context, state) => ContactUpdate(),
      ),
    ],
  );

  static GoRouter get router => _router;
}
