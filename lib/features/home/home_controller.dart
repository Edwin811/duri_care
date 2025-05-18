import 'package:duri_care/core/services/home_service.dart';
import 'package:duri_care/core/services/role_service.dart';
import 'package:duri_care/core/services/schedule_service.dart';
import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:duri_care/models/upcomingschedule.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

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
  final RxInt staffCount = 0.obs;

  RxString ucapan = ''.obs;

  RxString profilePicture = ''.obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadGreeting();
    loadUpcomingSchedule();
    getUsername();
    getProfilePicture();
    getRoleName();
    getStaffCount();
  }

  @override
  void onReady() {
    super.onReady();
    getUsername();
    getProfilePicture();
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

  Future<void> getUsername() async {
    try {
      final user = await UserService.to.getCurrentUser();
      username.value = user?.fullname ?? 'Guest';
    } catch (e) {
      username.value = 'Guest';
    }
  }

  Future<void> getProfilePicture() async {
    try {
      final user = await UserService.to.getCurrentUser();
      if (user?.profileUrl == null) {
        profilePicture.value = '';
      } else if (user!.profileUrl!.startsWith('http')) {
        profilePicture.value = user.profileUrl!;
      } else {
        profilePicture.value = Supabase.instance.client.storage
            .from('image')
            .getPublicUrl(user.profileUrl!);
      }
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

  Future<void> getStaffCount() async {
    staffCount.value = await UserService.to.countStaff();
  }

  Future<void> refreshUser() async {
    try {
      await getUsername();
      await getProfilePicture();
      await getRoleName();
    } catch (e) {
      debugPrint('Gagal refresh user: $e');
    }
  }
}
