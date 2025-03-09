import 'package:duri_care/features/auth/auth_state.dart';
import 'package:get/get.dart';
import 'package:duri_care/features/onboarding/onboarding_view.dart';

class AuthController extends GetxController {
  String tag = 'AuthController';
  static AuthController get find => Get.find();

  Rxn<AuthState> authState = Rxn();
  bool get isAuthenticated => authState.value == AuthState.authenticated;
  bool get isUnauthenticated => !isAuthenticated;

  @override
  void onReady() {
    ever(authState, authChanged);
    authState.value = AuthState.initial;
    super.onReady();
  }

  Future<void> authChanged(AuthState? state) async {
    authState.value = state;
    switch (state) {
      case AuthState.initial:
        break;
      case AuthState.unauthenticated:
      case AuthState.authenticated:
        Get.offAllNamed('/home');
      default:
        Get.toNamed(OnboardingView.route);
    }
  }
}