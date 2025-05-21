import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:duri_care/core/utils/storage_recovery.dart';

class SessionService extends GetxService {
  final GetStorage _box = GetStorage();
  final RxBool _isLoggedIn = false.obs;

  static SessionService get to => Get.find<SessionService>();

  final String _refreshTokenKey = 'refresh_token';

  Stream<bool> get authStateStream => _isLoggedIn.stream;
  bool get isLoggedIn => _isLoggedIn.value;
  Future<SessionService> init() async {
    // First ensure storage health
    await checkStorageHealth();

    try {
      final currentSession = Supabase.instance.client.auth.currentSession;
      final currentUser = Supabase.instance.client.auth.currentUser;

      // Read the refresh token from storage with extra safeguards
      String? refreshToken;
      try {
        // First check if the key exists before trying to read it
        if (_box.hasData(_refreshTokenKey)) {
          try {
            var rawValue = _box.read(_refreshTokenKey);

            // Check for known corruption pattern
            if (rawValue is String) {
              if (rawValue.contains('xhwc3k7zlbdd')) {
                debugPrint('Found corrupted refresh token! Removing...');
                await _box.remove(_refreshTokenKey);
                refreshToken = null;
              } else {
                refreshToken = rawValue;
              }
            } else {
              // Value is not a string - it's corrupted
              debugPrint(
                'Refresh token has wrong type: ${rawValue.runtimeType}',
              );
              await _box.remove(_refreshTokenKey);
              refreshToken = null;
            }
          } catch (e) {
            debugPrint('Error reading refresh token: $e');
            // If there's an error (especially FormatException), remove the corrupted key
            if (e is FormatException) {
              debugPrint('Format exception detected, attempting recovery');
              await StorageRecovery.handleFormatException(
                e,
                context: 'Reading refresh token',
              );
            }
            refreshToken = null;
          }
        } else {
          refreshToken = null;
        }
      } catch (e) {
        debugPrint('General error accessing refresh token: $e');
        refreshToken = null;
      }

      if (currentSession != null &&
          !currentSession.isExpired &&
          currentUser != null) {
        // Session is valid and user is logged in
        _isLoggedIn.value = true;
      } else if (refreshToken != null) {
        // Try to recover session using the refresh token
        try {
          // Use recoverSession with the refresh token
          final response = await Supabase.instance.client.auth.recoverSession(
            refreshToken,
          );
          final recoveredSession =
              response.session; // Access the session from the response

          if (recoveredSession != null && !recoveredSession.isExpired) {
            // Session recovered successfully
            _isLoggedIn.value = true;
            // Optionally save the new refresh token if it changed
            if (recoveredSession.refreshToken != null &&
                recoveredSession.refreshToken != refreshToken) {
              await _box.write(_refreshTokenKey, recoveredSession.refreshToken);
            }
          } else {
            // Recovery failed or session is expired, clear local data
            debugPrint(
              'Session recovery failed or expired after recovery attempt.',
            );
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
    try {
      // Verify the key exists before trying to remove it
      if (_box.hasData(_refreshTokenKey)) {
        await _box.remove(_refreshTokenKey);
        debugPrint('Refresh token removed in _clearLocalData');
      }

      // Extra check - try reading after removal to verify it's gone
      if (_box.hasData(_refreshTokenKey)) {
        debugPrint('WARNING: Refresh token still exists after removal attempt');

        // Try again with different approach
        try {
          await _box.write(_refreshTokenKey, null);
          await _box.remove(_refreshTokenKey);
          debugPrint('Second attempt to remove refresh token');
        } catch (e) {
          debugPrint('Error in second removal attempt: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in _clearLocalData: $e');

      // Last resort - try to erase everything
      try {
        await _box.erase();
        debugPrint('Erased all storage in _clearLocalData');
      } catch (eraseError) {
        debugPrint('Failed to erase storage: $eraseError');
      }
    }

    // Always set logged out state
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
  } // This getter is likely not needed if you only store the refresh token
  // If you need the access token, you should get it from the current Supabase session
  // String? get token => _box.read(_tokenKey); // Remove or revise this

  String? get refreshToken {
    try {
      // First check if the key exists
      if (!_box.hasData(_refreshTokenKey)) {
        return null;
      }

      try {
        var rawValue = _box.read(_refreshTokenKey);

        // Check for string type and corruption
        if (rawValue is String) {
          // Check for known corruption pattern
          if (rawValue.contains('xhwc3k7zlbdd')) {
            debugPrint('Found corrupted refresh token in getter! Removing...');
            _box.remove(_refreshTokenKey);
            return null;
          }
          return rawValue;
        } else {
          // Wrong type - should be a string
          debugPrint('Refresh token has wrong type: ${rawValue.runtimeType}');
          _box.remove(_refreshTokenKey);
          return null;
        }
      } catch (e) {
        debugPrint('Error reading refresh token in getter: $e');
        if (e is FormatException) {
          // Use our recovery helper
          StorageRecovery.handleFormatException(
            e,
            context: 'refreshToken getter',
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('General error in refreshToken getter: $e');
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      // Try to get all keys first - to make sure we can clear everything
      final allKeys = _box.getKeys<dynamic>();
      debugPrint('Clearing session with keys: $allKeys');

      // Clear important keys one by one
      await _box.remove('user_token');
      await _box.remove('user_id');
      await _box.remove('user_email');
      await _box.remove('user_role');
      await _box.remove('expires_at');
      await _box.remove('is_logged_in');

      // Extra safe removal of refresh token
      if (_box.hasData(_refreshTokenKey)) {
        await _box.remove(_refreshTokenKey);
        debugPrint('Refresh token removed successfully');
      }

      // Wait to ensure operations complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify clearing was successful
      if (_box.hasData(_refreshTokenKey)) {
        debugPrint('WARNING: Failed to remove refresh token!');
      }
    } catch (e) {
      debugPrint('Error during primary clearSession: $e');

      // Fallback plan: try three approaches to clean storage

      // 1. Try to remove keys individually
      try {
        final keys = _box.getKeys<dynamic>();
        debugPrint('Fallback cleanup - found keys: $keys');

        for (final key in keys) {
          try {
            await _box.remove(key);
            debugPrint('Removed key: $key');
          } catch (keyError) {
            debugPrint('Error removing key $key: $keyError');
          }
        }
      } catch (keysError) {
        debugPrint('Could not get keys: $keysError');
      }

      // 2. Try to erase the entire storage
      try {
        await _box.erase();
        debugPrint('Erased all GetStorage data');
      } catch (eraseError) {
        debugPrint('Error erasing GetStorage: $eraseError');
      }

      // 3. As a last resort, try to delete the file directly
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/GetStorage.gs');

        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted GetStorage file directly');

          // Re-init storage
          await GetStorage.init();
          debugPrint('Re-initialized GetStorage after file deletion');
        }
      } catch (fileError) {
        debugPrint('Could not delete GetStorage file: $fileError');
      }
    }

    // Always ensure logged out state
    _isLoggedIn.value = false;
  }

  // Check all storage for corruption and fix any issues
  Future<void> checkStorageHealth() async {
    debugPrint('Checking GetStorage health...');

    try {
      // Get all keys and check each one
      final keys = _box.getKeys<dynamic>();
      debugPrint('Found ${keys.length} keys in storage');

      List<String> corruptedKeys = [];

      for (final key in keys) {
        try {
          final value = _box.read(key);

          // Check for corruption in string values
          if (value is String && value.contains('xhwc3k7zlbdd')) {
            debugPrint('Found corrupted value for key: $key');
            corruptedKeys.add(key.toString());
          }
        } catch (e) {
          debugPrint('Error reading key $key: $e');
          if (e is FormatException) {
            corruptedKeys.add(key.toString());
          }
        }
      }

      // Fix any corrupted keys
      if (corruptedKeys.isNotEmpty) {
        debugPrint('Fixing ${corruptedKeys.length} corrupted keys...');
        for (final key in corruptedKeys) {
          try {
            await _box.remove(key);
            debugPrint('Removed corrupted key: $key');
          } catch (e) {
            debugPrint('Failed to remove corrupted key $key: $e');
          }
        }
      } else {
        debugPrint('No corruption found in GetStorage');
      }

      // Check storage file directly
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/GetStorage.gs');

        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint('GetStorage file size: $fileSize bytes');

          if (fileSize > 10000) {
            debugPrint('WARNING: Large GetStorage file detected');
          }

          // Check for corruption in file content
          try {
            final content = await file.readAsString();
            if (content.contains('xhwc3k7zlbdd')) {
              debugPrint(
                'Corruption detected in GetStorage file, recreating it',
              );

              // Backup important data
              final firstTime = _box.read<bool>('first_time');

              // Delete and reinitialize
              await file.delete();
              await GetStorage.init();

              // Restore important data
              if (firstTime != null) {
                await _box.write('first_time', firstTime);
              }

              debugPrint('GetStorage file recreated successfully');
            }
          } catch (readError) {
            debugPrint('Error reading GetStorage file: $readError');
          }
        }
      } catch (e) {
        debugPrint('Error checking GetStorage file: $e');
      }
    } catch (e) {
      debugPrint('Error checking storage health: $e');
    }
  }
}
