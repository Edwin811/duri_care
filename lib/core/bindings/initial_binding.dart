import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/home_service.dart';
import 'package:duri_care/core/services/notification_service.dart';
import 'package:duri_care/core/services/role_service.dart';
import 'package:duri_care/core/services/schedule_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/services/zone_service.dart';
import 'package:duri_care/core/utils/helpers/navigation/navigation_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/error/network_controller.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SessionService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(ZoneService(), permanent: true);
    Get.put(HomeService(), permanent: true);
    Get.put(RoleService(), permanent: true);
    Get.put(ScheduleService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    
    Get.put(NetworkController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(NavigationHelper(), permanent: true);
  }
}
