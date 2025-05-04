import 'package:duri_care/core/services/home_service.dart';
import 'package:duri_care/core/services/role_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Controller that manages the Home view data and state
class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeService _homeService = Get.find<HomeService>();
  final RoleService _roleService = Get.find<RoleService>();
  final zoneController = Get.put(ZoneController());
  final supabase = Supabase.instance.client;

  /// Username displayed in the UI
  final RxString username = ''.obs;
  final RxString role = ''.obs;

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
      isLoading.value = false;
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

  Future<String> getRoleName() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        role.value = await _roleService.getRoleName(userId);
        return role.value;
      } else {
        role.value = 'user';
        return role.value;
      }
    } catch (e) {
      return role.value;
    }
  }
}
