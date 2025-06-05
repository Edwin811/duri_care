import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:duri_care/core/utils/storage_recovery.dart';

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

      if (currentSupabaseSession != null &&
          currentSupabaseUser != null &&
          !currentSupabaseSession.isExpired) {
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
        try {
          final AuthResponse response = await supabaseClient.auth.setSession(
            storedRefreshToken,
          );
          if (response.session != null &&
              response.user != null &&
              !response.session!.isExpired) {
            _isLoggedIn.value = true;
            await saveSessionInternal(response.session!);
          } else {
            await clearLocalSessionData();
            _isLoggedIn.value = false;
          }
        } catch (e) {
          await clearLocalSessionData();
          _isLoggedIn.value = false;
        }
      } else {
        await clearLocalSessionData();
        _isLoggedIn.value = false;
      }
    } catch (e) {
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
          if (RegExp(r'^[a-zA-Z0-9]{30,}$').hasMatch(value) &&
              key == _refreshTokenKey) {
            _box.remove(key);
            return null;
          }
        }
        return value;
      } else if (value != null) {
        _box.remove(key);
      }
    } catch (e) {
      if (e is FormatException) {
        StorageRecovery.handleFormatException(e, context: "Reading key $key");
      }
      _box.remove(key);
    }
    return null;
  }

  Future<void> _performStorageHealthCheckAndRecovery() async {
    try {
      const testKey = '_storage_health_check_';
      await _box.write(testKey, DateTime.now().millisecondsSinceEpoch);
      _box.read(testKey);
      await _box.remove(testKey);
    } catch (e) {
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
  }

  Future<void> saveSession(Session session) async {
    await saveSessionInternal(session);
  }

  String? get refreshToken => _safelyReadString(_refreshTokenKey);
  String? get accessToken => _safelyReadString(_sessionAccessTokenKey);
  int? get sessionExpiryTime => _box.read<int>(_sessionExpiryKey);
  Future<void> clearLocalSessionData() async {
    await _box.remove(_refreshTokenKey);
    await _box.remove(_sessionAccessTokenKey);
    await _box.remove(_sessionExpiryKey);
    _isLoggedIn.value = false;
  }

  Future<void> clearSession() async {
    await clearLocalSessionData();
  }
}
