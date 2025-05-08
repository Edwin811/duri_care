import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString roleName = ''.obs;

  static UserService get to => Get.find<UserService>();

  // Future<UserService> init() async {
  //   final userData = SessionService.to.getUserData();
  //   if (userData != null) {
  //     loadUserFromMap(userData);
  //   }
  //   return this;
  // }

  void loadUserFromMap(Map<String, dynamic> data) {
    if (data.containsKey('auth') && data.containsKey('user')) {
      currentUser.value = UserModel.fromCombinedJson(
        data['auth'],
        data['user'],
      );
    } else {
      currentUser.value = UserModel(
        id: data['id'] ?? '',
        email: data['email'],
        lastSignInAt:
            data['last_sign_in_at'] != null
                ? DateTime.tryParse(data['last_sign_in_at'])
                : null,
        fullname: data['fullname'],
        profileUrl: data['profile_image'],
        roleId: data['role_id'],
        roleName: data['role_name'],
      );
    }
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
          lastSignInAt: authUser.lastSignInAt != null
              ? DateTime.tryParse(authUser.lastSignInAt!)
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
