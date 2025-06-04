import 'package:duri_care/core/routes/app_pages.dart';
import 'package:duri_care/features/error/error_404_view.dart';
import 'package:duri_care/features/error/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:duri_care/core/bindings/initial_binding.dart';
import 'package:flutter/services.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Future<T?> safeGetStorage<T>(String key, {T? defaultValue}) async {
//   try {
//     final box = GetStorage();
//     if (!box.hasData(key)) return defaultValue;

//     try {
//       return box.read<T>(key);
//     } catch (e) {
//       if (e is FormatException) {
//         try {
//           await box.remove(key);
//         } catch (_) {}
//       }
//       return defaultValue;
//     }
//   } catch (_) {
//     return defaultValue;
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await GetStorage.init();
  } catch (e) {
    debugPrint("GetStorage init failed, attempting recovery: $e");
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/GetStorage.gs');
      if (await file.exists()) {
        await file.delete();
        debugPrint("Deleted potentially corrupt GetStorage file.");
      }
      await GetStorage.init();
      debugPrint("GetStorage re-initialized successfully after recovery.");
    } catch (recoveryError) {
      debugPrint("GetStorage recovery also failed: $recoveryError");
    }
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );

  await Get.putAsync(() => SessionService().init(), permanent: true);

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
            child ?? const SizedBox(),
            Positioned.fill(
              child: Obx(() {
                return networkController.isConnected.value
                    ? const SizedBox.shrink()
                    : const Error404View();
              }),
            ),
          ],
        );
      },
    );
  }
}
