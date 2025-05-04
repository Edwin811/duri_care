import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:duri_care/core/services/user_service.dart';
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
    _loadCachedUsername();
    AuthService.to.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        authState.value = state.AuthState.authenticated;
        _refreshUserCache();
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
      await _refreshUserCache();
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
      final username = await getUsername();
      final userData = {
        'id': response.user!.id,
        'fullname': username,
        'profile_image': response.user!.userMetadata,
      };
      await SessionService.to.saveSession(
        response.session!.accessToken,
        userData,
      );
      await _refreshUserCache();
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
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('cached_username');
    });
  }

  Future<void> _refreshUserCache() async {
    final user = AuthService.to.currentUser;
    if (user == null) return;
    await Future.wait([
      getUsername().then((name) => _cachedUsername.value = name),
      getProfilePicture().then((pic) => _cachedProfilePicture.value = pic),
      getRole().then((role) => _cachedRole.value = role),
    ]);
  }

  Future<void> _loadCachedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('cached_username');
    if (savedUsername != null && savedUsername.isNotEmpty) {
      _cachedUsername.value = savedUsername;
    }
  }

  Future<void> _saveUsernameToCache(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_username', username);
  }

  Future<String> getUsername() async {
    if (_cachedUsername.value != null) {
      if (_lastUsernameFetch == null ||
          DateTime.now().difference(_lastUsernameFetch!) >
              _usernameRefreshInterval) {
        _refreshUsernameInBackground();
      }
      return _cachedUsername.value!;
    }
    final sessionData = await SessionService.to.getSession();
    if (sessionData != null && sessionData['fullname'] != null) {
      final fullname = sessionData['fullname'] as String;
      if (fullname.isNotEmpty) {
        _cachedUsername.value = fullname;
        _saveUsernameToCache(fullname);
        _lastUsernameFetch = DateTime.now();
        return fullname;
      }
    }
    final userModel = await UserService.to.getCurrentUser();
    if (userModel != null) {
      final fullname = userModel.fullname;
      if (fullname != null && fullname.trim().isNotEmpty) {
        _cachedUsername.value = fullname;
        _saveUsernameToCache(fullname);
        _lastUsernameFetch = DateTime.now();
        return fullname;
      } else {
        final email = userModel.email;
        if (email != null && email.trim().isNotEmpty) {
          final username = email.split('@').first;
          _cachedUsername.value = username;
          _saveUsernameToCache(username);
          _lastUsernameFetch = DateTime.now();
          return username;
        }
      }
    }
    return 'User';
  }

  Future<void> _refreshUsernameInBackground() async {
    try {
      final userModel = await UserService.to.getCurrentUser();
      if (userModel != null &&
          userModel.fullname != null &&
          userModel.fullname!.trim().isNotEmpty) {
        _cachedUsername.value = userModel.fullname;
        _saveUsernameToCache(userModel.fullname!);
      }
      _lastUsernameFetch = DateTime.now();
    } catch (e) {
      print('Background username refresh failed: $e');
    }
  }

  Future<String?> getEmail() async {
    if (_cachedEmail.value != null) {
      return _cachedEmail.value;
    }
    final user = AuthService.to.currentUser;
    _cachedEmail.value = user?.email;
    return user?.email;
  }

  Future<String> getProfilePicture() async {
    if (_cachedProfilePicture.value != null) {
      return _cachedProfilePicture.value!;
    }
    final user = AuthService.to.currentUser;
    if (user == null) return '';
    try {
      final sessionData = SessionService.to.getUserData();
      if (sessionData != null &&
          sessionData['profile_image'] != null &&
          sessionData['profile_image'] is String) {
        final profileImage = sessionData['profile_image'] as String;
        if (profileImage.isNotEmpty) {
          _cachedProfilePicture.value = profileImage;
          return profileImage;
        }
      }
      final userModel = await UserService.to.getCurrentUser();
      if (userModel != null &&
          userModel.profileUrl != null &&
          userModel.profileUrl!.isNotEmpty) {
        final publicUrl = AuthService.to.getPublicUrl(userModel.profileUrl!);
        _cachedProfilePicture.value = publicUrl;
        return publicUrl;
      }
      if (userModel != null &&
          userModel.fullname != null &&
          userModel.fullname!.isNotEmpty) {
        final initial = userModel.fullname![0].toUpperCase();
        _cachedProfilePicture.value = initial;
        return initial;
      }
      return '';
    } catch (e) {
      return '';
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
}
