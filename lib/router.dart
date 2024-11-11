import 'package:go_router/go_router.dart';
import 'package:snipper_frontend/design/accueil.dart';
import 'package:snipper_frontend/design/add-product.dart';
import 'package:snipper_frontend/design/affiliation-page-filleuls-details.dart';
import 'package:snipper_frontend/design/affiliation-page.dart';
import 'package:snipper_frontend/design/connexion.dart';
import 'package:snipper_frontend/design/email-oublier.dart';
import 'package:snipper_frontend/design/espace-partenaire.dart';
import 'package:snipper_frontend/design/fiche-contact.dart';
import 'package:snipper_frontend/design/inscription.dart';
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
import 'package:snipper_frontend/design/supscrition.dart';
import 'package:snipper_frontend/design/upload-pp.dart';
import 'package:snipper_frontend/design/your-products.dart';

class AppRouter {
  static GoRouter router(String? token) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final String? affiliationCode =
                state.uri.queryParametersAll['affiliationCode']?[0];
            final String? sellerId =
                state.uri.queryParametersAll['sellerId']?[0];
            final String? prdtId = state.uri.queryParametersAll['prdtId']?[0];

            print(token);
            

            return (token != null && token.isNotEmpty)
                ? Accueil(sellerId: sellerId, prdtId: prdtId)
                : Scene(affiliationCode: affiliationCode);
          },
        ),
        GoRoute(
          path: '/accueil',
          name: Accueil.id, // Use `Accueil.id` as the name here
          builder: (context, state) => Accueil(),
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
            final prdtAndUser = state.extra;

            return ProduitPage(prdtAndUser: prdtAndUser ?? {});
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
          path: '/${FicheContact.id}',
          name: FicheContact.id,
          builder: (context, state) => FicheContact(),
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
            final Map<String, dynamic> prdt =
                state.extra as Map<String, dynamic>;
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
      ],
    );
  }
}
