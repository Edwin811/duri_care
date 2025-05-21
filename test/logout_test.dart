import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/auth/auth_state.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock classes
class MockAuthService extends GetxService with Mock implements AuthService {
  @override
  Future<void> signOut() async {}
}

class MockSessionService extends GetxService
    with Mock
    implements SessionService {
  @override
  Future<void> clearSession() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Logout Flow Tests', () {
    late AuthController authController;
    late ProfileController profileController;
    late MockAuthService mockAuthService;
    late MockSessionService mockSessionService;

    setUpAll(() async {
      // Setup SharedPreferences for tests
      SharedPreferences.setMockInitialValues({
        'first_time': false,
        'other_key': 'some_value',
      });
    });

    setUp(() async {
      // Reset GetX bindings
      Get.reset();

      // Initialize mock services
      mockAuthService = MockAuthService();
      mockSessionService = MockSessionService();

      // Register services to Get
      Get.put<AuthService>(mockAuthService, permanent: true);
      Get.put<SessionService>(mockSessionService, permanent: true);
      Get.put<NavigationService>(NavigationService(), permanent: true);

      // Initialize controllers
      authController = AuthController();
      Get.put<AuthController>(authController, permanent: true);

      profileController = ProfileController();
      Get.put<ProfileController>(profileController);
    });

    testWidgets('Logout should preserve first_time preference', (
      WidgetTester tester,
    ) async {
      // Set initial state
      authController.authState.value = AuthState.authenticated;

      // Call logout method
      await authController.logout();

      // Verify first_time preference is preserved
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('first_time'), false);

      // Verify other preferences are cleared
      expect(prefs.getString('other_key'), null);

      // Verify auth state is set to unauthenticated
      expect(authController.authState.value, AuthState.unauthenticated);
    });

    testWidgets('Logout should navigate to login screen', (
      WidgetTester tester,
    ) async {
      // Build our app with a Navigation
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/profile',
          getPages: [
            GetPage(
              name: '/profile',
              page: () => const Scaffold(body: Text('Profile')),
            ),
            GetPage(
              name: '/login',
              page: () => const Scaffold(body: Text('Login')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Call logout method
      await authController.logout();
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.text('Login'), findsOneWidget);
    });
  });
}

// Simple Navigation Service for testing
class NavigationService extends GetxService {
  final RxInt currentIndex = 0.obs;

  void resetIndex() => currentIndex.value = 0;
}
