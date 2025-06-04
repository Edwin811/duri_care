import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/home/home_controller.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart' as auth_state_enum;

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService.to;
  final SessionService _sessionService = SessionService.to;
  final UserService _userService = UserService.to;

  Rx<auth_state_enum.AuthState> authState =
      auth_state_enum.AuthState.initial.obs;
  bool get isAuthenticated =>
      authState.value == auth_state_enum.AuthState.authenticated;
  bool get isUnauthenticated =>
      authState.value != auth_state_enum.AuthState.authenticated;
  RxBool isFirstTime = true.obs;

  final Rxn<String> _cachedUserId = Rxn<String>();
  final Rxn<String> _cachedUsername = Rxn<String>();
  final Rxn<String> _cachedEmail = Rxn<String>();
  final Rxn<String> _cachedRole = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _authService.authStateChanges.listen(_handleAuthStateChange);
  }

  @override
  void onReady() async {
    super.onReady();
    await checkFirstTimeUser();
    await updateAuthStateOnReady();
  }

  void _handleAuthStateChange(AuthState supabaseAuthState) {
    final AuthChangeEvent event = supabaseAuthState.event;
    final Session? session = supabaseAuthState.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      authState.value = auth_state_enum.AuthState.authenticated;
      _sessionService.saveSession(session);
      _refreshUserDataOnSignIn(session.user);
    } else if (event == AuthChangeEvent.signedOut) {
      _clearUserSessionAndState(preserveFirstTime: true);
    } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
      authState.value = auth_state_enum.AuthState.authenticated;
      _sessionService.saveSession(session);
      _refreshUserDataOnSignIn(session.user);
    } else if (event == AuthChangeEvent.userUpdated && session != null) {
      authState.value = auth_state_enum.AuthState.authenticated;
      _refreshUserDataOnSignIn(session.user);
    } else if (event == AuthChangeEvent.passwordRecovery) {
    } else {
      if (session == null) {
        if (authState.value != auth_state_enum.AuthState.initial &&
            authState.value != auth_state_enum.AuthState.unauthenticated) {
          _clearUserSessionAndState(preserveFirstTime: true);
        }
      }
    }
  }

  Future<void> updateAuthStateOnReady() async {
    if (isFirstTime.value) {
      authState.value = auth_state_enum.AuthState.initial;
    } else {
      final currentSupabaseSession = _supabase.auth.currentSession;
      if (currentSupabaseSession != null && !currentSupabaseSession.isExpired) {
        authState.value = auth_state_enum.AuthState.authenticated;
        await _sessionService.saveSession(currentSupabaseSession);
        await _refreshUserDataOnSignIn(currentSupabaseSession.user);
      } else {
        final recovered = await _sessionService.init();
        if (recovered.isLoggedIn) {
          authState.value = auth_state_enum.AuthState.authenticated;
          await _refreshUserDataOnSignIn(_supabase.auth.currentUser);
        } else {
          authState.value = auth_state_enum.AuthState.unauthenticated;
          await _clearUserSessionAndState(preserveFirstTime: true);
        }
      }
    }
  }

  Future<void> checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isFirstTime.value = prefs.getBool('first_time') ?? true;
    } catch (e) {
      isFirstTime.value = true;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_time', false);
      isFirstTime.value = false;
      authState.value = auth_state_enum.AuthState.unauthenticated;
    } catch (e) {
      // Silent error handling
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    return await _authService.signInWithPassword(email, password);
  }

  Future<void> _clearUserSessionAndState({
    bool preserveFirstTime = false,
  }) async {
    try {
      _cachedUserId.value = null;
      _cachedUsername.value = null;
      _cachedEmail.value = null;
      _cachedRole.value = null;

      final prefs = await SharedPreferences.getInstance();
      final bool firstTimeValue =
          preserveFirstTime ? (prefs.getBool('first_time') ?? true) : true;

      final keys = prefs.getKeys().toList();
      for (String key in keys) {
        if (key != 'first_time' || !preserveFirstTime) {
          await prefs.remove(key);
        }
      }

      await prefs.setBool('first_time', firstTimeValue);

      try {
        await _sessionService.clearSession();
      } catch (e) {
        // Silent error handling
      }

      await _resetControllers();
      authState.value = auth_state_enum.AuthState.unauthenticated;
    } catch (e) {
      _cachedUserId.value = null;
      _cachedUsername.value = null;
      _cachedEmail.value = null;
      _cachedRole.value = null;
      authState.value = auth_state_enum.AuthState.unauthenticated;
    }
  }

  Future<void> _resetControllers() async {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (homeController.initialized) {
          homeController.onClose();
          homeController.onInit();
        }
      }
    } catch (e) {
      // Silent error handling
    }

    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        if (profileController.initialized) {
          profileController.onClose();
          profileController.onInit();
        }
      }
    } catch (e) {
      // Silent error handling
    }

    try {
      if (Get.isRegistered<ZoneController>()) {
        final zoneController = Get.find<ZoneController>();
        if (zoneController.initialized) {
          zoneController.onClose();
          zoneController.onInit();
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      await Future.delayed(const Duration(milliseconds: 500));

      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }

      await Future.delayed(const Duration(milliseconds: 250));
      DialogHelper.showSuccessDialog(
        title: 'Berhasil Keluar',
        message: 'Anda telah berhasil keluar dari aplikasi.',
      );
    } catch (e) {
      try {
        await _clearUserSessionAndState(preserveFirstTime: true);
        authState.value = auth_state_enum.AuthState.unauthenticated;
      } catch (clearError) {
        // Silent error handling
      }

      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }

      DialogHelper.showErrorDialog(
        title: "Logout Error",
        message: "Terjadi kesalahan saat keluar: ${e.toString()}",
      );
    }
  }

  Future<void> _refreshUserDataOnSignIn(User? user) async {
    if (user == null) {
      await _clearUserSessionAndState(preserveFirstTime: true);
      return;
    }

    try {
      final userModel = await _userService.getCurrentUser(forceRefresh: true);
      if (userModel != null) {
        _cachedUserId.value = userModel.id;
        _cachedUsername.value = userModel.fullname;
        _cachedEmail.value = userModel.email;
        _cachedRole.value = userModel.roleName;
        await _refreshControllers();
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> _refreshControllers() async {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (homeController.initialized) {
          homeController.onReady();
        }
      }
    } catch (e) {
      // Silent error handling
    }

    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        if (profileController.initialized) {
          profileController.onInit();
        }
      }
    } catch (e) {
      // Silent error handling
    }

    try {
      if (Get.isRegistered<ZoneController>()) {
        final zoneController = Get.find<ZoneController>();
        if (zoneController.initialized) {
          zoneController.onInit();
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  String get currentUserId =>
      _cachedUserId.value ?? _supabase.auth.currentUser?.id ?? '';
  String get currentUsername => _cachedUsername.value ?? 'Guest';
  String get currentEmail => _cachedEmail.value ?? '';
  String? get currentRole => _cachedRole.value;

  String getUsername() => currentUsername;
  String getEmail() => currentEmail;
  String? getRole() => currentRole;
}
