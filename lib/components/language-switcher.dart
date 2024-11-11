import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSwitcher extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  LanguageSwitcher({required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.language),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Choose Language'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('English'),
                    onTap: () {
                      _changeLanguage(context, 'en');
                    },
                  ),
                  ListTile(
                    title: Text('Français'),
                    onTap: () {
                      _changeLanguage(context, 'fr');
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    Locale newLocale = Locale(languageCode);
    onLocaleChange(newLocale);
    context.pop();
  }
}
