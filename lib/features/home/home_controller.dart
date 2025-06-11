import 'dart:async';
import 'package:duri_care/core/services/home_service.dart';
import 'package:duri_care/core/services/role_service.dart';
import 'package:duri_care/core/services/schedule_service.dart';
import 'package:duri_care/core/services/sensor_service.dart';
import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/services/notification_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/auth/auth_state.dart' as auth_state_enum;
import 'package:duri_care/features/notification/notification_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:duri_care/models/upcomingschedule.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeService _homeService = Get.find<HomeService>();
  final RoleService _roleService = Get.find<RoleService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final SensorService sensorService = Get.find<SensorService>();
  final Rx<Upcomingschedule?> upcomingSchedule = Rx<Upcomingschedule?>(null);
  final ZoneController zoneController = Get.find<ZoneController>();
  final supabase = Supabase.instance.client;
  final RxString username = ''.obs;
  final RxString role = ''.obs;
  final RxInt unreadCount = 0.obs;
  final RxInt soilMoisture = 0.obs;
  final RxInt airTemperature = 0.obs;
  final RxInt airHumidity = 0.obs;
  final RxInt rainfallIntensity = 0.obs;
  final RxBool hasUnreadNotifications = false.obs;
  Timer? _sensorRefreshTimer;
  bool _isLoadingUserData = false;

  RxString ucapan = ''.obs;
  RxString profilePicture = ''.obs;
  RxBool isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    _loadGreeting();
    _initializeSensorData();

    ever(authController.authState, _handleAuthStateChange);
    if (authController.isAuthenticated) {
      refreshUserSpecificData();
    } else {
      clearUserData();
    }

    _setupNotificationSync();
  }

  @override
  void onClose() {
    _sensorRefreshTimer?.cancel();
    super.onClose();
  }

  void _initializeSensorData() {
    sensorService.initialLoad();

    ever(sensorService.latestSensorData, (data) {
      if (data != null) {
        _updateSensorValues(data);
      }
    });

    _sensorRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (authController.isAuthenticated) {
        sensorService.refreshData();
      }
    });
  }

  void _setupNotificationSync() {
    if (Get.isRegistered<NotificationController>()) {
      final notificationController = Get.find<NotificationController>();
      unreadCount.value = notificationController.unreadCount.value;
      hasUnreadNotifications.value =
          notificationController.hasUnreadNotifications;

      ever(notificationController.unreadCount, (int count) {
        unreadCount.value = count;
        hasUnreadNotifications.value = count > 0;
      });
    }
  }

  void _handleAuthStateChange(auth_state_enum.AuthState? authState) {
    if (authState == auth_state_enum.AuthState.authenticated) {
      refreshUserSpecificData();
    } else if (authState == auth_state_enum.AuthState.unauthenticated) {
      clearUserData();
    }
  }

  void clearUserData() {
    username.value = 'Guest';
    role.value = '';
    profilePicture.value = '';
    upcomingSchedule.value = null;
    unreadCount.value = 0;
    hasUnreadNotifications.value = false;
  }

  Future<void> refreshUserSpecificData() async {
    if (!authController.isAuthenticated || _isLoadingUserData) {
      clearUserData();
      return;
    }

    _isLoadingUserData = true;
    isLoading.value = true;
    try {
      await Future.wait([
        loadUpcomingSchedule(),
        getUsername(),
        getProfilePicture(),
        getRoleName(),
        _loadNotificationCount(),
        refreshSensorData(),
      ]);
    } catch (e) {
      DialogHelper.showErrorDialog(message: 'Failed to load user data: $e');
    } finally {
      isLoading.value = false;
      _isLoadingUserData = false;
    }
  }

  void _loadGreeting() {
    ucapan.value = _homeService.getGreeting();
  }

  Future<void> loadUpcomingSchedule() async {
    if (!authController.isAuthenticated) {
      upcomingSchedule.value = null;
      return;
    }
    try {
      final schedule = await scheduleService.getUpcomingScheduleWithZone();
      upcomingSchedule.value = schedule;
    } catch (e) {
      upcomingSchedule.value = null;
    }
  }

  Future<void> getSensorData({bool forceRefresh = false}) async {
    try {
      Map<String, dynamic>? data;

      if (forceRefresh) {
        data = await sensorService.forceRefresh();
      } else {
        data = sensorService.getCachedSensorData();
      }

      if (data != null) {
        _updateSensorValues(data);
      } else {
        _resetSensorValues();
      }
    } catch (error) {
      _resetSensorValues();
    }
  }

  void _updateSensorValues(Map<String, dynamic> data) {
    soilMoisture.value = data['soil_moisture'] ?? 0;
    airTemperature.value = data['air_temperature'] ?? 0;
    airHumidity.value = data['air_humidity'] ?? 0;
    rainfallIntensity.value = data['rainfall_intensity'] ?? 0;

    soilMoisture.refresh();
    airTemperature.refresh();
    airHumidity.refresh();
    rainfallIntensity.refresh();
  }

  void _resetSensorValues() {
    soilMoisture.value = 0;
    airTemperature.value = 0;
    airHumidity.value = 0;
    rainfallIntensity.value = 0;
  }

  Future<void> refreshSensorData() async {
    await sensorService.refreshData();
  }

  Future<void> getUsername() async {
    if (!authController.isAuthenticated) {
      username.value = 'Guest';
      return;
    }
    try {
      final user = await UserService.to.getCurrentUser(forceRefresh: false);
      username.value = user?.fullname ?? await authController.getUsername();
    } catch (e) {
      username.value = await authController.getUsername();
    }
  }

  String getInitialsFromName(String name) {
    if (name.isEmpty || name == "Guest") return '?';

    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';

    if (nameParts.length == 1) {
      if (nameParts[0].isNotEmpty) {
        return nameParts[0][0].toUpperCase();
      }
      return '?';
    }

    final firstInitial =
        nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    final secondInitial =
        nameParts.length > 1 && nameParts[1].isNotEmpty
            ? nameParts[1][0].toUpperCase()
            : '';

    if (firstInitial.isEmpty && secondInitial.isEmpty) return '?';
    return '$firstInitial$secondInitial';
  }

  Future<void> getProfilePicture() async {
    if (!authController.isAuthenticated) {
      profilePicture.value = '';
      return;
    }
    try {
      final user = await UserService.to.getCurrentUser(forceRefresh: false);
      if (user?.profileUrl == null || user?.profileUrl?.isEmpty == true) {
        profilePicture.value = getInitialsFromName(username.value);
      } else if (user!.profileUrl!.startsWith('http')) {
        profilePicture.value = user.profileUrl!;
      } else {
        final publicUrl = Supabase.instance.client.storage
            .from('image')
            .getPublicUrl(user.profileUrl!);
        profilePicture.value = publicUrl;
      }
    } catch (e) {
      profilePicture.value = getInitialsFromName(username.value);
    }
  }

  Future<void> getRoleName() async {
    if (!authController.isAuthenticated) {
      role.value = '';
      return;
    }
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final roleFromService = await _roleService.getRoleName(userId);
        role.value = roleFromService;
      } else {
        role.value = 'user';
      }
    } catch (e) {
      role.value = 'user';
    }
  }

  Future<void> _loadNotificationCount() async {
    if (!authController.isAuthenticated) {
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;
      return;
    }

    try {
      if (Get.isRegistered<NotificationController>()) {
        final notificationController = Get.find<NotificationController>();
        await notificationController.loadNotifications();
      } else {
        await refreshNotificationCount();
      }
    } catch (e) {
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;
    }
  }

  Future<void> triggerUIRefresh() async {
    if (!authController.isAuthenticated || _isLoadingUserData) return;
    _isLoadingUserData = true;
    isLoading.value = true;
    await Future.wait([
      getUsername(),
      getProfilePicture(),
      getRoleName(),
      _loadNotificationCount(),
      refreshSensorData(),
    ]);
    isLoading.value = false;
    _isLoadingUserData = false;
  }

  Future<void> refreshNotificationCount() async {
    if (!authController.isAuthenticated) return;

    try {
      final notificationService = Get.find<NotificationService>();
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final notifications = await notificationService.getUserNotifications(
          userId,
        );
        final count = notifications.where((n) => !n.isRead).length;
        unreadCount.value = count;
        hasUnreadNotifications.value = count > 0;
        if (Get.isRegistered<NotificationController>()) {
          final notificationController = Get.find<NotificationController>();
          notificationController.unreadCount.value = count;
        }
      }
    } catch (e) {}
  }

  void onNotificationRead() {
    if (unreadCount.value > 0) {
      unreadCount.value = unreadCount.value - 1;
      hasUnreadNotifications.value = unreadCount.value > 0;
    }
  }

  void onAllNotificationsRead() {
    unreadCount.value = 0;
    hasUnreadNotifications.value = false;
  }

  void onNotificationDeleted(bool wasUnread) {
    if (wasUnread && unreadCount.value > 0) {
      unreadCount.value = unreadCount.value - 1;
      hasUnreadNotifications.value = unreadCount.value > 0;
    }
  }

  void onPageVisible() {
    sensorService.refreshData();
  }

  void onAppResumed() {
    refreshUserSpecificData();
    sensorService.refreshData();
  }
}
