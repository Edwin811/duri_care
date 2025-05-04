import 'package:duri_care/core/services/home_service.dart';
import 'package:duri_care/core/services/role_service.dart';
import 'package:duri_care/core/services/schedule_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:duri_care/models/upcomingschedule.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeService _homeService = Get.find<HomeService>();
  final RoleService _roleService = Get.find<RoleService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final Rx<Upcomingschedule?> upcomingSchedule = Rx<Upcomingschedule?>(null);
  final zoneController = Get.put(ZoneController());
  final supabase = Supabase.instance.client;

  final RxString username = ''.obs;
  final RxString role = ''.obs;

  RxString ucapan = ''.obs;

  RxString profilePicture = ''.obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadGreeting();
    loadUserData();
    loadUpcomingSchedule();
  }

  void _loadGreeting() {
    ucapan.value = _homeService.getGreeting();
  }

  Future<void> loadUpcomingSchedule() async {
    try {
      isLoading.value = true;
      final schedule = await scheduleService.getUpcomingScheduleWithZone();
      if (schedule != null) {
        upcomingSchedule.value = schedule;
      } else {
        upcomingSchedule.value = null;
      }
    } catch (e) {
      upcomingSchedule.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        authController.getUsername(),
        authController.getProfilePicture(),
        getRoleName(),
      ]);
      username.value = results[0];
      profilePicture.value = results[1];
      role.value = results[2];
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
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
