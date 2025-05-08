import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionService extends GetxService {
  final GetStorage _box = GetStorage();
  final RxBool _isLoggedIn = false.obs;

  static SessionService get to => Get.find<SessionService>();

  // Use a different key for the refresh token
  final String _refreshTokenKey = 'refresh_token';

  Stream<bool> get authStateStream => _isLoggedIn.stream;
  bool get isLoggedIn => _isLoggedIn.value;

  Future<SessionService> init() async {
    try {
      final currentSession = Supabase.instance.client.auth.currentSession;
      final currentUser = Supabase.instance.client.auth.currentUser;

      // Read the refresh token from storage
      final refreshToken = _box.read(_refreshTokenKey);

      if (currentSession != null &&
          !currentSession.isExpired &&
          currentUser != null) {
        // Session is valid and user is logged in
        _isLoggedIn.value = true;
      } else if (refreshToken != null) {
        // Try to recover session using the refresh token
        try {
          // Use recoverSession with the refresh token
          final response = await Supabase.instance.client.auth.recoverSession(refreshToken);
          final recoveredSession = response.session; // Access the session from the response

          if (recoveredSession != null && !recoveredSession.isExpired) {
            // Session recovered successfully
            _isLoggedIn.value = true;
            // Optionally save the new refresh token if it changed
             if (recoveredSession.refreshToken != null && recoveredSession.refreshToken != refreshToken) {
                 await _box.write(_refreshTokenKey, recoveredSession.refreshToken);
             }
          } else {
            // Recovery failed or session is expired, clear local data
            debugPrint('Session recovery failed or expired after recovery attempt.');
            await _clearLocalData();
          }
        } catch (e) {
          debugPrint('Session recovery failed with exception: $e');
          await _clearLocalData();
        }
      } else {
        // No active session and no refresh token in storage
        _isLoggedIn.value = false;
      }
    } catch (e) {
      debugPrint('Session initialization error: $e');
      _isLoggedIn.value = false;
    }

    return this;
  }

  Future<void> _clearLocalData() async {
    // Clear the refresh token from storage
    await _box.remove(_refreshTokenKey);
    _isLoggedIn.value = false;
  }

  // Modify saveSession to accept and save the refresh token
  Future<void> saveSession(Session session) async {
    if (session.refreshToken != null) {
       await _box.write(_refreshTokenKey, session.refreshToken);
       _isLoggedIn.value = true;
    } else {
        debugPrint('Attempted to save session but refreshToken was null.');
        _isLoggedIn.value = false; // Ensure logged out state if no refresh token
    }
  }

  // This getter is likely not needed if you only store the refresh token
  // If you need the access token, you should get it from the current Supabase session
  // String? get token => _box.read(_tokenKey); // Remove or revise this

  String? get refreshToken => _box.read(_refreshTokenKey);


  Future<void> clearSession() async {
    await _clearLocalData();
    await Supabase.instance.client.auth.signOut(); // Also sign out from Supabase

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Check if GetMaterialApp is registered and context is available
        if (Get.isRegistered<GetMaterialApp>() && Get.context != null) {
          final currentRoute = Get.currentRoute;
          // Only navigate if not already on login or splash
          if (currentRoute != '/login' && currentRoute != '/splash') {
            Get.offAllNamed('/login');
          }
        } else {
           // Fallback navigation if GetMaterialApp or context is not available
           // This might happen in tests or specific scenarios
           debugPrint('GetMaterialApp not registered or context not available for navigation.');
           // You might want to use a different navigation approach here if needed
        }
      } catch (e) {
        debugPrint('Navigation error during clearSession: $e');
      }
    });
  }
}
