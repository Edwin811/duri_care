import 'package:duri_care/features/profile/edit_profile_view.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'profile_view.dart';
import 'package:get/get.dart';

final profileRoute = [
  GetPage(
    name: ProfileView.route,
    page: () => ProfileView(),
    binding: BindingsBuilder(() {
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>();
      }
      Get.put(ProfileController());
    }),
  ),
];

final editProfileRoute = [
  GetPage(
    name: '/edit-profile',
    page: () => const EditProfileView(),
    binding: BindingsBuilder(() {
      Get.lazyPut<ProfileController>(() => ProfileController());
    }),
    transition: Transition.cupertino,
    transitionDuration: const Duration(milliseconds: 300),
  ),
];
