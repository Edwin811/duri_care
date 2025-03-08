import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'languages/en_US.dart';
import 'languages/id_ID.dart';

class LocalizationHelper {
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBoxName);
  }

  static Map<String, Locale> get availableLocales => {
    'id': const Locale('id', 'ID'),
    'en': const Locale('en', 'US'),
  };

  static Map<String, String> get languageMap => {
    'txt_indonesian': 'id',
    'txt_english': 'en',
  };

  static Locale get currentLocale {
    String currentLanguageCode = Hive.box(
      settingsBoxName,
    ).get('locale', defaultValue: 'en');
    return availableLocales[currentLanguageCode] ?? const Locale('en', 'US');
  }

  static Future<void> setLocale(String languageCode) async {
    await Hive.box(settingsBoxName).put('locale', languageCode);
  }

  static void changeLanguage(BuildContext context, String languageKey) {
    String languageCode = languageMap[languageKey] ?? 'en';
    setLocale(languageCode);

    final state = context.findRootAncestorStateOfType<LocalizedAppState>();
    if (state != null) {
      state.setLocale(availableLocales[languageCode]!);
    }
  }

  static String translate(String key, {String? languageCode}) {
    final code = languageCode ?? currentLocale.languageCode;

    switch (code) {
      case 'id':
        return id_ID[key] ?? key;
      case 'en':
      default:
        return en_US[key] ?? key;
    }
  }
}

class LocalizedApp extends StatefulWidget {
  final Widget child;

  const LocalizedApp({super.key, required this.child});

  @override
  LocalizedAppState createState() => LocalizedAppState();

  static LocalizedAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<LocalizedAppState>();
  }
}

class LocalizedAppState extends State<LocalizedApp> {
  Locale _locale = LocalizationHelper.currentLocale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: _locale,
      delegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      child: widget.child,
    );
  }
}

extension TranslateString on String {
  String get tr => LocalizationHelper.translate(this);
}
