import 'package:flutter/material.dart';
import 'package:snipper_frontend/localization/app_localizations.dart'; // Ensure you import your localization class

extension TranslateX on BuildContext {
  String translate(String key, {Map<String, dynamic>? args}) {
    String translation = AppLocalizations.of(this).translate(key);

    if (args != null) {
      args.forEach((key, value) {
        translation = translation.replaceAll('{$key}', value.toString());
      });
    }

    return translation;
  }
}
