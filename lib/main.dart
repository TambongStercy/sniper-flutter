import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snipper_frontend/localization/app_localizations.dart';
import 'package:snipper_frontend/router.dart';
import 'package:snipper_frontend/theme.dart'; // Import our new theme

// Conditional import
import 'web_url_strategy.dart' if (dart.library.io) 'default_url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Call the platform-specific setPathUrlStrategy function
  setPathUrlStrategy();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // For languages
  Locale? _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  final _router = AppRouter.router;

  @override
  
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      locale: _locale,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: 'Snipper Business Center',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(), // Use our new theme
      // darkTheme: AppTheme.darkTheme(), // Optionally enable dark theme
      // themeMode: ThemeMode.system,
    );
  }
}
