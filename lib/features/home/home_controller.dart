import 'package:duri_care/core/services/home_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Controller that manages the Home view data and state
class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeService _homeService = Get.find<HomeService>();
  final zoneController = Get.put(ZoneController());
  final supabase = Supabase.instance.client;

  /// Username displayed in the UI
  final RxString username = ''.obs;

  /// Time-based greeting message (e.g., "Selamat Pagi")
  RxString ucapan = ''.obs;

  /// User's profile picture URL or initial
  RxString profilePicture = ''.obs;

  /// Loading state indicator
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadGreeting();
    loadUserData();
  }

  /// Loads the greeting message based on the current time
  void _loadGreeting() {
    ucapan.value = _homeService.getGreeting();
  }

  /// Loads all user-related data (username and profile picture)
  Future<void> loadUserData() async {
    try {
      username.value = await authController.getUsername();
      profilePicture.value = await authController.getProfilePicture();
      isLoading.value = false;
    } catch (e) {
      // Handle error but ensure loading state is updated
      isLoading.value = false;
    }
  }

  /// Gets the user's name with error handling
  Future<void> getName() async {
    try {
      final name = await authController.getUsername();
      username.value = name;
    } catch (e) {
      username.value = 'User';
    }
  }

  /// Gets the user's profile picture with error handling
  Future<void> getProfilePicture() async {
    try {
      final picture = await authController.getProfilePicture();
      profilePicture.value = picture;
    } catch (e) {
      profilePicture.value = '';
    }
  }
}
