import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class StorageRecovery {
  /// Forcibly clears GetStorage by deleting the underlying file
  /// Use this as a last resort when corruption is detected
  static Future<bool> forceResetGetStorage() async {
    try {
      debugPrint('Starting emergency GetStorage recovery...');

      // Get the storage file path
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/GetStorage.gs');

      // Check if the file exists
      if (await file.exists()) {
        // Try to read and log file content for debugging
        try {
          final content = await file.readAsString();
          final sampleContent =
              content.length > 100
                  ? content.substring(0, 100) + '...'
                  : content;
          debugPrint('GetStorage content sample: $sampleContent');
        } catch (e) {
          debugPrint('Could not read GetStorage file: $e');
        }

        // Delete the file
        await file.delete();
        debugPrint('Deleted GetStorage file');

        // Reinitialize GetStorage
        await GetStorage.init();
        debugPrint('Reinitialized GetStorage after forced reset');

        return true;
      } else {
        debugPrint('GetStorage file not found, nothing to reset');
        return false;
      }
    } catch (e) {
      debugPrint('Error during forced GetStorage reset: $e');
      return false;
    }
  }

  /// Attempts to fix a FormatException by identifying and removing corrupted keys
  static Future<bool> handleFormatException(
    FormatException e, {
    String? context,
  }) async {
    debugPrint('FormatException detected: ${e.message} (context: $context)');

    // If this is the specific corruption pattern we've seen
    if (e.message.contains('xhwc3k7zlbdd')) {
      debugPrint('Detected known corruption pattern, attempting recovery');
      return await forceResetGetStorage();
    }

    // Try to repair without full reset
    try {
      final box = GetStorage();
      final keys = box.getKeys<dynamic>();

      debugPrint('Checking ${keys.length} keys for corruption');

      List<String> suspiciousKeys = [];

      // Try to identify corrupted keys
      for (final key in keys) {
        try {
          box.read(key);
        } catch (keyError) {
          debugPrint('Found corrupted key: $key');
          suspiciousKeys.add(key.toString());
        }
      }

      if (suspiciousKeys.isNotEmpty) {
        // Remove corrupted keys
        for (final key in suspiciousKeys) {
          try {
            await box.remove(key);
            debugPrint('Removed corrupted key: $key');
          } catch (removeError) {
            debugPrint('Failed to remove key $key: $removeError');
          }
        }

        return true;
      } else {
        // If we couldn't identify specific keys, do a full reset
        debugPrint('Could not identify corrupted keys, performing full reset');
        return await forceResetGetStorage();
      }
    } catch (e) {
      debugPrint('Error repairing GetStorage: $e');
      // Last resort
      return await forceResetGetStorage();
    }
  }
}
