import 'package:duri_care/features/auth/auth_state.dart';
import 'package:get/get.dart';
import 'package:duri_care/features/onboarding/onboarding_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthController extends GetxController {
  static AuthController get find => Get.find();
  final _box = Hive.box('authBox');

  Rxn<AuthState> authState = Rxn();
  bool get isAuthenticated => authState.value == AuthState.authenticated;
  bool get isUnauthenticated => !isAuthenticated;

  RxBool isFirstTime = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(authState, authChanged);
  }

  @override
  void onReady() async {
    super.onReady();
    await checkFirstTimeUser();
    _updateAuthState();
  }

  void _updateAuthState() {
    if (isFirstTime.value) {
      authState.value = AuthState.initial;
    } else {
      authState.value =
          _box.get('isLoggedIn', defaultValue: false)
              ? AuthState.authenticated
              : AuthState.unauthenticated;
    }
  }

  Future<void> checkFirstTimeUser() async {
    isFirstTime.value = _box.get('first_time', defaultValue: true);
  }

  Future<void> completeOnboarding() async {
    await _box.put('first_time', false);
    isFirstTime.value = false;
    authState.value = AuthState.unauthenticated;
  }

  Future<void> authChanged(AuthState? state) async {
    authState.value = state;
    switch (state) {
      case AuthState.initial:
        Get.offAllNamed('/onboarding');
        break;
      case AuthState.unauthenticated:
        Get.offAllNamed('/login');
        break;
      case AuthState.authenticated:
        Get.offAllNamed('/home');
        break;
      default:
        break;
    }
  }

  Future<void> login(String userId) async {
    await _box.put('isLoggedIn', true);
    await _box.put('userId', userId);
    authState.value = AuthState.authenticated;
  }

  Future<void> logout() async {
    await _box.put('isLoggedIn', false);
    await _box.delete('userId');
    authState.value = AuthState.unauthenticated;
  }
}
