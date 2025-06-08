import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart' as auth_state_enum;

class AuthController extends GetxController {
  Rxn<auth_state_enum.AuthState> authState = Rxn();
  bool get isAuthenticated =>
      authState.value == auth_state_enum.AuthState.authenticated;
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
    AuthService.to.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        authState.value = auth_state_enum.AuthState.authenticated;
        _refreshUserData();
      } else if (event == AuthChangeEvent.signedOut) {
        _clearCacheAndResetStates();
        authState.value = auth_state_enum.AuthState.unauthenticated;
      } else {
        if (AuthService.to.currentUser == null) {
          authState.value = auth_state_enum.AuthState.unauthenticated;
        } else {
          authState.value = auth_state_enum.AuthState.authenticated;
        }
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
      authState.value = auth_state_enum.AuthState.initial;
    } else if (session?.user != null) {
      authState.value = auth_state_enum.AuthState.authenticated;
    } else {
      authState.value = auth_state_enum.AuthState.unauthenticated;
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
    authState.value = auth_state_enum.AuthState.unauthenticated;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await AuthService.to.signInWithPassword(email, password);
    if (response.user != null) {
      await SessionService.to.saveSession(response.session!);
      authState.value = auth_state_enum.AuthState.authenticated;
      await _refreshUserData();
    } else {
      authState.value = auth_state_enum.AuthState.unauthenticated;
    }
    return response;
  }

  Future<void> logout() async {
    try {
      await _clearCacheAndResetStates();

      try {
        await AuthService.to.signOut();
      } catch (e) {}

      authState.value = auth_state_enum.AuthState.unauthenticated;

      Get.offAllNamed('/login', predicate: (_) => false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogHelper.showSuccessDialog(
          title: 'Berhasil',
          message: 'Anda telah keluar dari aplikasi',
        );
      });
    } catch (e) {
      authState.value = auth_state_enum.AuthState.unauthenticated;
      Get.offAllNamed('/login', predicate: (_) => false);
    }
  }

  Future<void> _clearCacheAndResetStates() async {
    _cachedUsername.value = null;
    _cachedEmail.value = null;
    _cachedProfilePicture.value = null;
    _cachedRole.value = null;
    _lastUsernameFetch = null;

    final prefs = await SharedPreferences.getInstance();
    final firstTimeValue = prefs.getBool('first_time') ?? false;
    await prefs.clear();
    await prefs.setBool('first_time', firstTimeValue);

    try {
      final box = GetStorage();
      final List<String> keys = box.getKeys().cast<String>().toList();
      for (final key in keys) {
        try {
          await box.remove(key);
        } catch (keyError) {}
      }
    } catch (e) {
      try {
        final box = GetStorage();
        await box.erase();
      } catch (eraseError) {
        try {
          await GetStorage.init();
        } catch (initError) {}
      }
    }

    await SessionService.to.clearSession();
  }

  Future<void> _refreshUserData() async {
    if (isAuthenticated && AuthService.to.currentUser != null) {
      await Future.wait([getUsername(), getEmail(), getRole()]);
    }
  }

  Future<String> getUsername() async {
    final user = AuthService.to.currentUser;
    if (user == null) return 'Guest';

    if (_cachedUsername.value != null &&
        _lastUsernameFetch != null &&
        DateTime.now().difference(_lastUsernameFetch!) <
            _usernameRefreshInterval) {
      return _cachedUsername.value!;
    }
    try {
      final profile = await AuthService.to.getUserProfile(user.id);
      final fullname = profile?['fullname'] as String?;
      if (fullname != null && fullname.isNotEmpty) {
        _cachedUsername.value = fullname;
        _lastUsernameFetch = DateTime.now();
        return fullname;
      }
    } catch (e) {}
    final fallbackUsername = user.email?.split('@').first ?? 'Guest';
    _cachedUsername.value = fallbackUsername;
    return fallbackUsername;
  }

  Future<String> getEmail() async {
    final user = AuthService.to.currentUser;
    if (user == null) return '';
    _cachedEmail.value = user.email ?? '';
    return _cachedEmail.value!;
  }

  Future<String?> getRole() async {
    final user = AuthService.to.currentUser;
    if (user == null) return null;

    if (_cachedRole.value != null) {
      return _cachedRole.value;
    }
    final role = await AuthService.to.getUserRole(user.id);
    _cachedRole.value = role;
    return role;
  }

  void refreshUsername() {
    _lastUsernameFetch = null;
    getUsername();
  }

  String get currentUsername => _cachedUsername.value ?? 'Guest';
  String get currentEmail => _cachedEmail.value ?? '';
  String? get currentRole => _cachedRole.value;
}
