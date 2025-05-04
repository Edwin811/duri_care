import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:duri_care/core/services/session_service.dart';

/// Service responsible for handling home view related operations
class HomeService extends GetxService {
  final _storage = GetStorage();
  final SessionService _sessionService = Get.find<SessionService>();

  static HomeService get to => Get.find<HomeService>();

  /// Initializes the home service
  Future<HomeService> init() async {
    return this;
  }

  /// Returns the appropriate greeting based on the time of day
  String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 3 && hour < 10) {
      return "Selamat Pagi";
    } else if (hour >= 10 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  /// Retrieves the cached username for the user
  Future<String> getCachedUsername(String userId) async {
    return await _sessionService.getCachedUsername(userId) ?? 'User';
  }

  /// Retrieves the cached profile picture for the user
  Future<String> getCachedProfilePicture(String userId) async {
    final profilePic = _storage.read('profile_image_$userId');
    return profilePic ?? '';
  }
}
