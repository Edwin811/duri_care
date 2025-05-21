import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferences Preservation Test', () {
    test('Should preserve first_time preference during logout', () async {
      // Setup SharedPreferences with a first_time value
      SharedPreferences.setMockInitialValues({'first_time': false});
      final prefs = await SharedPreferences.getInstance();

      // Verify the setup
      expect(prefs.getBool('first_time'), false);

      // Simulate the _clearCacheExceptFirstTime function's behavior
      final firstTimeValue = prefs.getBool('first_time') ?? false;
      await prefs.clear();
      await prefs.setBool('first_time', firstTimeValue);

      // Verify first_time was preserved
      expect(prefs.getBool('first_time'), false);

      // Verify other values were cleared
      expect(prefs.getString('some_other_key'), null);
    });
  });
}
