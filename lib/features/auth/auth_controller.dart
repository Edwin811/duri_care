import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart' as state;

class AuthController extends GetxController {
  static AuthController get find => Get.find();

  Rxn<state.AuthState> authState = Rxn();
  bool get isAuthenticated =>
      authState.value == state.AuthState.authenticated;
  bool get isUnauthenticated => !isAuthenticated;

  RxBool isFirstTime = true.obs;

  @override
  void onInit() {
    super.onInit();
    removeFirstTimeUser();

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
    await _updateAuthState();
  }

  Future<void> _updateAuthState() async {
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

  Future<void> removeFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('first_time');
    isFirstTime.value = true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    isFirstTime.value = false;
    authState.value = state.AuthState.unauthenticated;
  }

  Future<void> login(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    authState.value = state.AuthState.authenticated;
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    authState.value = state.AuthState.unauthenticated;
    authState.refresh();
  }
}
