import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

abstract class DialogHelper {
  static void showErrorDialogSafely({
    required String message,
    String? title,
    VoidCallback? onConfirm,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showErrorDialog(message: message, title: title, onConfirm: onConfirm);
    });
  }

  static Future<void> showErrorDialog({
    required String message,
    String? title,
    VoidCallback? onConfirm,
  }) async {
    if (Get.context == null) return;

    Timer? autoCloseTimer;
    autoCloseTimer = Timer(const Duration(seconds: 10), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });

    return Get.dialog(
      Dialog(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/error.json',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                title ?? 'Error',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onConfirm?.call();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) => autoCloseTimer?.cancel());
  }

  static Future<void> showSuccessDialog({
    required String message,
    String? title,
    VoidCallback? onConfirm,
  }) async {
    if (Get.context == null) return;

    Timer? autoCloseTimer;
    autoCloseTimer = Timer(const Duration(seconds: 10), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });

    return Get.dialog(
      Dialog(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/success.json',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                title ?? 'Success',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    autoCloseTimer?.cancel();
                    Get.back();
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => autoCloseTimer?.cancel());
  }

  static Future<void> showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    int autoCloseTime = 10,
  }) async {
    if (Get.context == null) return;

    Timer? autoCloseTimer;
    autoCloseTimer = Timer(Duration(seconds: autoCloseTime), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });

    return Get.dialog(
      Dialog(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/warning.json',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      autoCloseTimer?.cancel();
                      onCancel();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(120, 50),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      autoCloseTimer?.cancel();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(120, 50),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) => autoCloseTimer?.cancel());
  }

  static void closeDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static void showSnackBar({
    required String message,
    String? title,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    if (Get.context == null) return;

    Get.snackbar(
      title ?? (isError ? 'Error' : 'Info'),
      message,
      snackPosition: position,
      backgroundColor: isError ? Colors.red.shade50 : Colors.green.shade50,
      colorText: isError ? Colors.red.shade800 : Colors.green.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? Colors.red : Colors.green,
      ),
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
