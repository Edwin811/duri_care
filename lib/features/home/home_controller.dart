import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final zoneController = Get.put(ZoneController());
  final supabase = Supabase.instance.client;
  final RxString username = ''.obs;
  RxString ucapan = ''.obs;
  RxString profilePicture = ''.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _getSpeech();
    loadUserData();
  }

  Future<void> loadUserData() async {
    username.value = await authController.getUsername();
    profilePicture.value = await authController.getProfilePicture();

  }

  void _getSpeech() {
    DateTime now = DateTime.now();
    int jam = now.hour;

    if (jam >= 3 && jam < 10) {
      ucapan.value = "Selamat Pagi";
    } else if (jam >= 10 && jam < 15) {
      ucapan.value = "Selamat Siang";
    } else if (jam >= 15 && jam < 18) {
      ucapan.value = "Selamat Sore";
    } else {
      ucapan.value = "Selamat Malam";
    }
  }

  Future<void> getName() async {
    try {
      final name = await authController.getUsername();
      username.value = name ?? 'User';
    } catch (e) {
      username.value = 'User';
    }
  }

  Future<void> getProfilePicture() async {
    try {
      final picture = await authController.getProfilePicture();
      profilePicture.value = picture;
    } catch (e) {
      profilePicture.value = '';
    }
  }
}
