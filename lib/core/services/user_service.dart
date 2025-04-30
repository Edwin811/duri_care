import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/user/user_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Rx<UserModel> currentUser = Rx<UserModel>(UserModel());

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
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response =
          await _supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (response != null) {
        final userModel = UserModel.fromSupabaseData(response);
        currentUser.value = userModel;
        return userModel;
      }
      return currentUser.value;
    } catch (e) {
      DialogHelper.showErrorDialog(message: 'Gagal mendapatkan data user: $e');
    }
  }
}
