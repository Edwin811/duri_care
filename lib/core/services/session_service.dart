import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:duri_care/core/utils/storage_recovery.dart'; // Pastikan path ini benar

class SessionService extends GetxService {
  final GetStorage _box = GetStorage();
  final RxBool _isLoggedIn = false.obs;

  static SessionService get to => Get.find<SessionService>();

  final String _refreshTokenKey = 'refresh_token';
  final String _sessionExpiryKey = 'session_expiry_time';
  final String _sessionAccessTokenKey = 'session_access_token';

  Stream<bool> get authStateStream => _isLoggedIn.stream;
  bool get isLoggedIn => _isLoggedIn.value;

  Future<SessionService> init() async {
    await _performStorageHealthCheckAndRecovery();

    try {
      final String? storedRefreshToken = _safelyReadString(_refreshTokenKey);
      final String? storedAccessToken = _safelyReadString(
        _sessionAccessTokenKey,
      );
      final int? storedExpiryTime = _box.read<int>(_sessionExpiryKey);

      final SupabaseClient supabaseClient = Supabase.instance.client;
      final Session? currentSupabaseSession =
          supabaseClient.auth.currentSession;
      final User? currentSupabaseUser = supabaseClient.auth.currentUser;

      debugPrint(
        "SessionService Init: Stored RefreshToken: ${storedRefreshToken != null ? "Exists" : "Null"}",
      );
      debugPrint(
        "SessionService Init: Stored AccessToken: ${storedAccessToken != null ? "Exists" : "Null"}",
      );
      debugPrint("SessionService Init: Stored ExpiryTime: $storedExpiryTime");
      debugPrint(
        "SessionService Init: Supabase CurrentSession: ${currentSupabaseSession != null ? "Exists" : "Null"}, User: ${currentSupabaseUser != null ? "Exists" : "Null"}",
      );

      if (currentSupabaseSession != null &&
          currentSupabaseUser != null &&
          !currentSupabaseSession.isExpired) {
        debugPrint(
          "SessionService Init: Active Supabase session found and not expired.",
        );
        _isLoggedIn.value = true;
        if (currentSupabaseSession.refreshToken != null &&
            currentSupabaseSession.refreshToken != storedRefreshToken) {
          await _box.write(
            _refreshTokenKey,
            currentSupabaseSession.refreshToken,
          );
        }
        if (currentSupabaseSession.accessToken != storedAccessToken) {
          await _box.write(
            _sessionAccessTokenKey,
            currentSupabaseSession.accessToken,
          );
        }
        if (currentSupabaseSession.expiresAt != null &&
            currentSupabaseSession.expiresAt != storedExpiryTime) {
          await _box.write(_sessionExpiryKey, currentSupabaseSession.expiresAt);
        }
      } else if (storedRefreshToken != null) {
        debugPrint(
          "SessionService Init: No active Supabase session, attempting recovery with stored refresh token.",
        );
        try {
          final AuthResponse response = await supabaseClient.auth.setSession(
            storedRefreshToken,
          );

          if (response.session != null &&
              response.user != null &&
              !response.session!.isExpired) {
            debugPrint("SessionService Init: Session recovered successfully.");
            _isLoggedIn.value = true;
            await saveSessionInternal(response.session!);
          } else {
            debugPrint(
              "SessionService Init: Session recovery failed or session expired after recovery. Clearing local data.",
            );
            await clearLocalSessionData();
            _isLoggedIn.value = false;
          }
        } catch (e) {
          debugPrint(
            "SessionService Init: Exception during session recovery: $e. Clearing local data.",
          );
          await clearLocalSessionData();
          _isLoggedIn.value = false;
        }
      } else {
        debugPrint(
          "SessionService Init: No active Supabase session and no stored refresh token. User is logged out.",
        );
        await clearLocalSessionData();
        _isLoggedIn.value = false;
      }
    } catch (e) {
      debugPrint(
        "SessionService Init: General error during initialization: $e. Assuming logged out.",
      );
      await clearLocalSessionData();
      _isLoggedIn.value = false;
    }
    return this;
  }

  String? _safelyReadString(String key) {
    if (!_box.hasData(key)) return null;
    try {
      final dynamic value = _box.read(key);
      if (value is String) {
        if (value.length > 30 && !value.contains('.') && !value.contains('{')) {
          // Heuristik sederhana untuk ID vs token JWT
          if (RegExp(r'^[a-zA-Z0-9]{30,}$').hasMatch(value) &&
              key == _refreshTokenKey) {
            // Lebih spesifik untuk refresh token
            debugPrint(
              "Potentially corrupted token-like string found for key '$key': $value. Removing.",
            );
            _box.remove(key);
            return null;
          }
        }
        return value;
      } else if (value != null) {
        debugPrint(
          "Value for key '$key' is not a String (type: ${value.runtimeType}). Removing.",
        );
        _box.remove(key);
      }
    } catch (e) {
      debugPrint("Error reading key '$key' from GetStorage: $e");
      if (e is FormatException) {
        StorageRecovery.handleFormatException(e, context: "Reading key $key");
      }
      _box.remove(key);
    }
    return null;
  }

  Future<void> _performStorageHealthCheckAndRecovery() async {
    debugPrint("Performing GetStorage health check...");
    try {
      const testKey = '_storage_health_check_';
      await _box.write(testKey, DateTime.now().millisecondsSinceEpoch);
      _box.read(testKey);
      await _box.remove(testKey);
      debugPrint("GetStorage health check passed.");
    } catch (e) {
      debugPrint(
        "GetStorage health check failed: $e. Attempting forced reset.",
      );
      await StorageRecovery.forceResetGetStorage();
    }
  }

  Future<void> saveSessionInternal(Session session) async {
    await _box.write(_refreshTokenKey, session.refreshToken);
    await _box.write(_sessionAccessTokenKey, session.accessToken);
    if (session.expiresAt != null) {
      await _box.write(_sessionExpiryKey, session.expiresAt);
    } else {
      await _box.remove(_sessionExpiryKey);
    }
    _isLoggedIn.value = true;
    debugPrint("Session data saved to local storage. Refresh token stored.");
  }

  Future<void> saveSession(Session session) async {
    await saveSessionInternal(session);
  }

  String? get refreshToken => _safelyReadString(_refreshTokenKey);
  String? get accessToken => _safelyReadString(_sessionAccessTokenKey);
  int? get sessionExpiryTime => _box.read<int>(_sessionExpiryKey);

  Future<void> clearLocalSessionData() async {
    debugPrint("Clearing local session data from SessionService...");
    await _box.remove(_refreshTokenKey);
    await _box.remove(_sessionAccessTokenKey);
    await _box.remove(_sessionExpiryKey);
    _isLoggedIn.value = false;
    debugPrint("Local session data cleared. User set to logged out.");
  }

  Future<void> clearSession() async {
    await clearLocalSessionData();
  }
}
