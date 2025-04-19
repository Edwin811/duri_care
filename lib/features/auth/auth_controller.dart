import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart' as state;

class AuthController extends GetxController {
  Rxn<state.AuthState> authState = Rxn();
  bool get isAuthenticated => authState.value == state.AuthState.authenticated;
  bool get isUnauthenticated => !isAuthenticated;
  RxBool isFirstTime = true.obs;
  final SupabaseClient _supabase = Supabase.instance.client;
  @override
  void onInit() {
    super.onInit();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        authState.value = state.AuthState.authenticated;
      } else if (event == AuthChangeEvent.signedOut) {
        authState.value = state.AuthState.unauthenticated;
      } else {
        authState.value = state.AuthState.unauthenticated;
      }
    });
  }

  @override
  void onReady() async {
    super.onReady();
    await checkFirstTimeUser();
    await updateAuthState();
  }

  Future<void> updateAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (isFirstTime.value) {
      authState.value = state.AuthState.initial;
    } else if (session?.user != null) {
      authState.value = state.AuthState.authenticated;
    } else {
      authState.value = state.AuthState.unauthenticated;
    }
  }

  Future<void> checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstTime.value = prefs.getBool('first_time') ?? true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    isFirstTime.value = false;
    authState.value = state.AuthState.unauthenticated;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    authState.value = state.AuthState.authenticated;
    return response;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    authState.value = state.AuthState.unauthenticated;
    authState.refresh();
  }

  Future<String?> getUsername() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response =
          await _supabase
              .from('users')
              .select('fullname')
              .eq('id', user.id)
              .maybeSingle();

      if (response != null && response['fullname'] != null) {
        return response['fullname'];
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        '$e'
      );
    }

    // Fallback to email if no fullname found or query fails
    return user.email?.split('@').first;
  }

  Future<String> getProfilePicture() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final avatarUrl = user.userMetadata?['avatar_url'];
      if (avatarUrl != null) {
        return avatarUrl;
      }

      String? username = await getUsername();
      if (username != null && username.isNotEmpty) {
        return username[0].toUpperCase();
      }
    }
    return '';
  }
}
