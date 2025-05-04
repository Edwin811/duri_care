import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton pattern
  static AuthService get to => Get.find<AuthService>();

  Future<AuthService> init() async {
    return this;
  }

  // Authentication methods
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // User data methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await _supabase
        .from('users')
        .select('profile_image, fullname, email')
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

  // Storage methods
  String getPublicUrl(String path) {
    return _supabase.storage.from('duricare').getPublicUrl(path);
  }

  // Auth state
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Current user
  User? get currentUser => _supabase.auth.currentUser;

  // Current session
  Session? get currentSession => _supabase.auth.currentSession;
}
