import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/home/home_controller.dart';
import 'package:duri_care/features/login/login_controller.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
    AuthService.to.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        authState.value = state.AuthState.authenticated;
        _refreshUserData();
      } else if (event == AuthChangeEvent.signedOut) {
        _clearCacheExceptFirstTime();
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
    try {
      await _clearCacheExceptFirstTime();

      authState.value = state.AuthState.unauthenticated;

      try {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          profileController.disposeControllerResources();
          Get.delete<ProfileController>(force: true);
        }

        if (Get.isRegistered<LoginController>()) {
          Get.delete<LoginController>(force: true);
        }

        if (Get.isRegistered<HomeController>()) {
          Get.delete<HomeController>(force: true);
        }
      } catch (e) {
        debugPrint('Error removing controllers: $e');
      }

      try {
        await AuthService.to.signOut();
      } catch (e) {
        debugPrint('Error during Supabase sign out: $e');
      }

      await Future.delayed(const Duration(milliseconds: 150));

      Get.offAllNamed('/login', predicate: (_) => false);

      await Future.delayed(const Duration(milliseconds: 300));
      DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: 'Anda telah keluar dari aplikasi',
      );
    } catch (e) {
      debugPrint('Error during logout: $e');
      Get.offAllNamed('/login', predicate: (_) => false);
    }
  }

  Future<void> _clearCacheExceptFirstTime() async {
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
      // Try to safely clear GetStorage
      try {
        // Get all keys first
        final keys = box.getKeys<dynamic>();
        // Clear each key individually to avoid corrupting the whole storage
        for (final key in keys) {
          try {
            await box.remove(key);
          } catch (keyError) {
            debugPrint('Error removing key $key: $keyError');
          }
        }
      } catch (keysError) {
        debugPrint('Error getting GetStorage keys: $keysError');
      }

      // As a fallback, try the erase method
      try {
        await box.erase();
      } catch (eraseError) {
        debugPrint('Error erasing GetStorage: $eraseError');
      }
    } catch (e) {
      debugPrint('Error accessing GetStorage: $e');
      // Try to recover by reinitializing
      try {
        await GetStorage.init();
      } catch (initError) {
        debugPrint('Failed to reinitialize GetStorage: $initError');
      }
    }

    await SessionService.to.clearSession();
  }

  Future<void> _refreshUserData() async {
    await Future.wait([getUsername(), getEmail(), getRole()]);
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
      _lastUsernameFetch = currentTime;
    }
  }
}
