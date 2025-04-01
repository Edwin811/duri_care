import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';

class SyncButton extends StatefulWidget {
  const SyncButton({super.key});

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotate() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _rotate,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: -_controller.value * 2 * 3.14,
            child: const Icon(Icons.sync),
          );
        },
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColor.greenSecondary.withAlpha(120),
        foregroundColor: AppColor.greenPrimary,
        padding: EdgeInsets.all(4),
        shape: const CircleBorder(),
        minimumSize: const Size(20, 20),
      ),
    );
  }
}
