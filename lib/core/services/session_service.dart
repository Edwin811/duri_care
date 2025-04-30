import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SessionService extends GetxService {
  final GetStorage _box = GetStorage();
  final RxBool _isLoggedIn = false.obs;
  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>>({});

  static SessionService get to => Get.find<SessionService>();

  final String _tokenKey = 'auth_token';
  final String _userDataKey = 'user_data';

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

  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    await _box.write(_tokenKey, token);
    await _box.write(_userDataKey, user);
    _isLoggedIn.value = true;
    userData.value = user;
  }

  String? get token => _box.read(_tokenKey);

  Map<String, dynamic>? getUserData() {
    return _box.read(_userDataKey);
  }

  Future<void> clearSession() async {
    await _box.remove(_tokenKey);
    await _box.remove(_userDataKey);
    _isLoggedIn.value = false;
    userData.value = {};
  }

  Future<void> updateUserData(Map<String, dynamic> user) async {
    await _box.write(_userDataKey, user);
    userData.value = user;
  }
}
