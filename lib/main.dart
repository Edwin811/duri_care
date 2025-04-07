import 'package:duri_care/core/routes/app_pages.dart';
import 'package:duri_care/features/error/error_404_view.dart';
import 'package:duri_care/features/error/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:duri_care/core/bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Supabase.initialize(
    url: 'https://mglmoopyqftrvmuuvwyf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nbG1vb3B5cWZ0cnZtdXV2d3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2MjczMzMsImV4cCI6MjA1ODIwMzMzM30.59imX2uRXxMUcnk_8jk_CAgoRhGl32KyGVT9Ut5M9l8',
  );

  runApp(const DuriCare());
}

class DuriCare extends StatelessWidget {
  const DuriCare({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      builder: (context, child) {
        return Obx(() {
          final networkController = Get.find<NetworkController>();
          final showError = !networkController.isConnected.value;
          return Stack(children: [child!, if (showError) const Error404View()]);
        });
      },
    );
  }
}
