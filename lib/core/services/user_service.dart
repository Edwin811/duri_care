import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Rx<UserModel> currentUser = Rx<UserModel>(UserModel());
  final RxString roleName = ''.obs;

  static UserService get to => Get.find<UserService>();

  Future<UserService> init() async {
    final userData = SessionService.to.getUserData();
    if (userData != null) {
      loadUserFromMap(userData);
    }
    return this;
  }

  void loadUserFromMap(Map<String, dynamic> data) {
    currentUser.value = UserModel.fromSupabaseData(data);
  }

  Future<UserModel?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    try {
      final response =
          await _supabase
              .from('users')
              .select('fullname, profile_image')
              .eq('id', authUser.id)
              .maybeSingle();

      if (response != null) {
        final userModel = UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          createdAt: DateTime.parse(authUser.createdAt),
          lastSignInAt:
              authUser.lastSignInAt != null
                  ? DateTime.parse(authUser.lastSignInAt!)
                  : null,
          fullname: response['fullname'] ?? '',
          profileUrl: response['profile_image'],
        );

        currentUser.value = userModel;
        return userModel;
      } else {
        final userModel = UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          createdAt: DateTime.parse(authUser.createdAt),
          lastSignInAt:
              authUser.lastSignInAt != null
                  ? DateTime.parse(authUser.lastSignInAt!)
                  : null,
          fullname: '',
          profileUrl: null,
        );

        currentUser.value = userModel;
        return userModel;
      }
    } catch (e) {
      DialogHelper.showErrorDialog(message: 'Gagal mendapatkan data user: $e');
      return null;
    }
  }
}
