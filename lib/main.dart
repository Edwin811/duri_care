import 'package:duri_care/core/routes/app_pages.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/error/error_404_view.dart';
import 'package:duri_care/features/error/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:duri_care/core/bindings/initial_binding.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    DialogHelper.showErrorDialog(message: "Failed to load environment variables. Please check your .env file.");
    return;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await GetStorage.init();
  } catch (e) {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/GetStorage.gs');
      if (await file.exists()) {
        await file.delete();
      }
      await GetStorage.init();
    } catch (recoveryError) {
      DialogHelper.showErrorDialog(
        message: "Failed to initialize storage. Please check your device's storage.",
      );
      return;
    }
  }
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    return;
  }

  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } catch (e) {
    return;
  }
  runApp(const DuriCare());
}

class DuriCare extends StatelessWidget {
  const DuriCare({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      builder: (context, child) {
        final networkController = Get.find<NetworkController>();
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            Obx(() {
              return networkController.isConnected.value
                  ? const SizedBox.shrink()
                  : const Positioned.fill(child: Error404View());
            }),
          ],
        );
      },
    );
  }
}
