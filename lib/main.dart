import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snipper_frontend/localization/app_localizations.dart';
import 'package:snipper_frontend/router.dart';

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
      theme: ThemeData(
        // Enable Material Design 3
        useMaterial3: true,

        // Use ColorScheme.fromSeed but explicitly define primary, secondary, tertiary
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color(0xff1862f0), // Keep blue as the seed for generation
          brightness: Brightness.light,
          // Explicitly set the main colors from the logo
          primary: const Color(0xff1862f0), // Blue
          secondary: const Color(0xff92b127), // Lime Green
          tertiary: const Color(
              0xffED8B00), // Orange (using the one defined in utils.dart)
        ),

        // Keep existing scrollbar theme for now, might need adjustment for M3
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all(true),
          thickness: MaterialStateProperty.all(6.0),
          radius: const Radius.circular(4.0),
        ),
        // Add other M3 theme adjustments if necessary (e.g., textTheme, component themes)
      ),
      // Optionally define a dark theme
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xff1862f0),
      //     brightness: Brightness.dark,
      //   ),
      //   // Add other dark theme adjustments
      // ),
      // themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark
    );
  }
}
