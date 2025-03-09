import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back_ios_rounded,
  });
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!, width: 1.5),
        ),
        child: Center(
          child: IconButton(
            onPressed: onPressed ?? () => Get.back(),
            icon: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}
