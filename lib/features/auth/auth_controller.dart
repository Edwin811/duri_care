import 'package:duri_care/features/auth/auth_state.dart';
import 'package:get/get.dart';
import 'package:duri_care/features/onboarding/onboarding_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  String tag = 'AuthController';
  static AuthController get find => Get.find();

  Rxn<AuthState> authState = Rxn();
  bool get isAuthenticated => authState.value == AuthState.authenticated;
  bool get isUnauthenticated => !isAuthenticated;

  RxBool isFirstTime = true.obs;

  @override
  void onReady() async {
    await checkFirstTimeUser();
    ever(authState, authChanged);
    authState.value = AuthState.initial;
    super.onReady();
  }

  Future<void> checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstTime.value = prefs.getBool('first_time') ?? true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    isFirstTime.value = false;
    authState.value = AuthState.unauthenticated;
  }

  Future<void> authChanged(AuthState? state) async {
    authState.value = state;
    switch (state) {
      case AuthState.initial:
        if (isFirstTime.value) {
          Get.offAllNamed(OnboardingView.route);
        } else {
          authState.value = AuthState.unauthenticated;
        }
        break;
      case AuthState.unauthenticated:
        Get.offAllNamed('/login');
        break;
      case AuthState.authenticated:
        Get.offAllNamed('/home');
        break;
      default:
        if (isFirstTime.value) {
          Get.toNamed(OnboardingView.route);
        } else {
          Get.offAllNamed('/login');
        }
    }
  }
}
