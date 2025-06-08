import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class StorageRecovery {
  static Future<bool> forceResetGetStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/GetStorage.gs');

      if (await file.exists()) {
        await file.delete();
        await GetStorage.init();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> handleFormatException(
    FormatException e, {
    String? context,
  }) async {
    if (e.message.contains('xhwc3k7zlbdd')) {
      return await forceResetGetStorage();
    }

    try {
      final box = GetStorage();
      final keys = box.getKeys<dynamic>();

      List<String> suspiciousKeys = [];

      for (final key in keys) {
        try {
          box.read(key);
        } catch (keyError) {
          suspiciousKeys.add(key.toString());
        }
      }

      if (suspiciousKeys.isNotEmpty) {
        for (final key in suspiciousKeys) {
          try {
            await box.remove(key);
          } catch (removeError) {}
        }
        return true;
      } else {
        return await forceResetGetStorage();
      }
    } catch (e) {
      return await forceResetGetStorage();
    }
  }
}
