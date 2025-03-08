import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/utils/localization/localization_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalizationHelper.init();

  runApp(const DuriCare());
}

class DuriCare extends StatelessWidget {
  const DuriCare({super.key});

  @override
  Widget build(BuildContext context) {
    return LocalizedApp(
      child: GetMaterialApp(
        title: 'Duri Care',
        locale: LocalizationHelper.currentLocale,
        supportedLocales: LocalizationHelper.availableLocales.values.toList(),
        theme: ThemeData(primarySwatch: Colors.blue),
        // home: const HomeScreen(),
      ),
    );
  }
}
