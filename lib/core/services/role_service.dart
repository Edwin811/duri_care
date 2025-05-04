import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static RoleService get to => Get.find<RoleService>();

  Future<RoleService> init() async {
    return this;
  }

  Future<String> getRoleName(String userId) async {
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
