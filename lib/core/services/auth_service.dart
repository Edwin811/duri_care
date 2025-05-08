import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static AuthService get to => Get.find<AuthService>();

  Future<AuthService> init() async {
    return this;
  }

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await _supabase
        .from('users')
        .select('profile_image, fullname')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<String?> getUserRole(String userId) async {
    final response =
        await _supabase
            .from('user_roles')
            .select('roles ( role_name )')
            .eq('user_id', userId)
            .maybeSingle();

    if (response == null) return null;
    return response['roles']?['role_name'];
  }

  String getPublicUrl(String path) {
    return _supabase.storage.from('duricare').getPublicUrl(path);
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Session? get currentSession => _supabase.auth.currentSession;
}
