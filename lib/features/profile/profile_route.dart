import 'package:duri_care/features/profile/edit_profile_view.dart';
import 'package:duri_care/features/profile/profile_controller.dart';

import 'profile_binding.dart';
import 'profile_view.dart';
import 'package:get/get.dart';

final profileRoute = [
  GetPage(
    name: ProfileView.route,
    page: () => ProfileView(),
    binding: BindingsBuilder(() {
      // Jika sudah ada controller, buang dan buat baru
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>();
      }
      Get.put(ProfileController());
    }),
  ),
];

final editProfileRoute = [
  GetPage(
    name: EditProfileView.route,
    page: () => EditProfileView(),
    binding: ProfileBinding(),
  ),
];
