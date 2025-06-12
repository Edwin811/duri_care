import 'package:duri_care/core/services/connectivity_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  static RoleService get to => Get.find<RoleService>();

  Future<RoleService> init() async {
    return this;
  }

  Future<String> getRoleName(String userId) async {
    if (!await _connectivity.hasInternetConnection()) {
      return 'user';
    }

    try {
      final response =
          await _supabase
              .from('user_roles')
              .select('roles(role_name)')
              .eq('user_id', userId)
              .maybeSingle();

      if (response != null && response['roles'] != null) {
        return response['roles']['role_name'] ?? 'user';
      } else {
        return 'user';
      }
    } catch (error) {
      return 'user';
    }
  }
}
