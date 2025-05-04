import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Service responsible for managing user sessions and local storage of user data
class SessionService extends GetxService {
  final GetStorage _box = GetStorage();

  /// Observable to track user login state
  final RxBool _isLoggedIn = false.obs;

  /// Local storage instance for caching user data
  final _storage = GetStorage();

  /// Observable containing current user data
  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>>({});

  /// Provides access to the service via GetX dependency injection
  static SessionService get to => Get.find<SessionService>();

  /// Keys for storing authentication data
  final String _tokenKey = 'auth_token';
  final String _userDataKey = 'user_data';

  /// Initializes the session service and loads existing session if available
  Future<SessionService> init() async {
    final token = _box.read(_tokenKey);
    if (token != null) {
      _isLoggedIn.value = true;

      final data = _box.read(_userDataKey);
      if (data != null) {
        userData.value = Map<String, dynamic>.from(data);
      }
    }
    return this;
  }

  /// Caches the username for a specific user ID
  Future<void> cacheUsername(String userId, String fullname) async {
    await _storage.write('username_$userId', fullname);
  }

  /// Retrieves the cached username for a specific user ID
  Future<String?> getCachedUsername(String userId) async {
    return _storage.read('username_$userId');
  }

  /// Caches the profile picture URL for a specific user ID
  Future<void> cacheProfilePicture(String userId, String profilePicture) async {
    await _storage.write('profile_image_$userId', profilePicture);
  }

  /// Clears cached data for a specific user ID
  Future<void> clearUserCache(String userId) async {
    await _storage.remove('username_$userId');
    await _storage.remove('profile_image_$userId');
  }

  /// Saves the user session data and token
  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    await _box.write(_tokenKey, token);
    await _box.write(_userDataKey, user);
    _isLoggedIn.value = true;
    userData.value = user;
  }

  /// Gets the stored authentication token
  String? get token => _box.read(_tokenKey);

  /// Gets the stored user data
  Map<String, dynamic>? getUserData() {
    return _box.read(_userDataKey);
  }

  /// Clears the session data on logout
  Future<void> clearSession() async {
    await _box.remove(_tokenKey);
    await _box.remove(_userDataKey);
    _isLoggedIn.value = false;
    userData.value = {};
  }

  /// Updates the stored user data
  Future<void> updateUserData(Map<String, dynamic> user) async {
    await _box.write(_userDataKey, user);
    userData.value = user;
  }
}
