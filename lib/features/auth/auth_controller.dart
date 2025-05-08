import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/services/user_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart' as state;

class AuthController extends GetxController {
  Rxn<state.AuthState> authState = Rxn();
  bool get isAuthenticated => authState.value == state.AuthState.authenticated;
  bool get isUnauthenticated => !isAuthenticated;
  RxBool isFirstTime = true.obs;

  final Rxn<String> _cachedUsername = Rxn<String>();
  final Rxn<String> _cachedEmail = Rxn<String>();
  final Rxn<String> _cachedProfilePicture = Rxn<String>();
  final Rxn<String> _cachedRole = Rxn<String>();
  DateTime? _lastUsernameFetch;
  static const _usernameRefreshInterval = Duration(minutes: 30);

  @override
  void onInit() {
    super.onInit();
    getProfilePicture();
    AuthService.to.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        authState.value = state.AuthState.authenticated;
        _refreshUserData();
      } else if (event == AuthChangeEvent.signedOut) {
        _clearCache();
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
    if (isAuthenticated) {
      await _refreshUserData();
    }
  }

  Future<void> updateAuthState() async {
    final session = AuthService.to.currentSession;
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
    final response = await AuthService.to.signInWithPassword(email, password);
    if (response.user != null) {
      await SessionService.to.saveSession(response.session!);
      await _refreshUserData();
    }
    authState.value = state.AuthState.authenticated;
    return response;
  }

  Future<void> logout() async {
    await AuthService.to.signOut();
    await SessionService.to.clearSession();
    _clearCache();
    authState.value = state.AuthState.unauthenticated;
    authState.refresh();
    Get.offAllNamed('/login');
  }

  void _clearCache() {
    _cachedUsername.value = null;
    _cachedEmail.value = null;
    _cachedProfilePicture.value = null;
    _cachedRole.value = null;
    _lastUsernameFetch = null;
  }

  Future<void> _refreshUserData() async {
    await _refreshUserData();
    await getProfilePicture();
    await getUsername();
    await getEmail();
    await getRole();
  }

  Future<String> getUsername() async {
    final user = AuthService.to.currentUser;
    if (user == null) return 'Guest';

    try {
      final profile = await AuthService.to.getUserProfile(user.id);
      final fullname = profile?['fullname'] as String?;
      if (fullname != null && fullname.isNotEmpty) {
        return fullname;
      }
    } catch (e) {
      debugPrint('Gagal ambil profil user: $e');
    }

    return user.email?.split('@').first ?? 'Guest';
  }

  Future<String> getEmail() async {
    final user = AuthService.to.currentUser;
    if (user == null) return '';
    try {
      return user.email ?? '';
    } catch (e) {
      throw Exception('Failed to get email: $e');
    }
  }

  Future<String> getProfilePicture() async {
    final user = await UserService.to.getCurrentUser();
    if (user == null || user.profileUrl == null) return '';

    final publicUrl = Supabase.instance.client.storage
        .from('duricare')
        .getPublicUrl(user.profileUrl!);
    debugPrint('Profile picture: $publicUrl');

    return publicUrl;
  }

  Future<String?> getRole() async {
    if (_cachedRole.value != null) {
      return _cachedRole.value;
    }
    final user = AuthService.to.currentUser;
    if (user == null) return null;
    final role = await AuthService.to.getUserRole(user.id);
    _cachedRole.value = role;
    return role;
  }

  void refreshUsername() {
    final currentTime = DateTime.now();
    if (_lastUsernameFetch == null ||
        currentTime.difference(_lastUsernameFetch!).inMinutes >
            _usernameRefreshInterval.inMinutes) {
      // Fetch username logic
      _lastUsernameFetch = currentTime;
    }
  }
}
