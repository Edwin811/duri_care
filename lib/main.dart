import 'package:duri_care/core/routes/app_pages.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mglmoopyqftrvmuuvwyf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nbG1vb3B5cWZ0cnZtdXV2d3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2MjczMzMsImV4cCI6MjA1ODIwMzMzM30.59imX2uRXxMUcnk_8jk_CAgoRhGl32KyGVT9Ut5M9l8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
