import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SyncButton extends StatefulWidget {
  const SyncButton({super.key, required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotate() async {
    await widget.onRefresh();
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      for (int i = 0; i < 2; i++) {
        await _controller.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _rotate,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: const Icon(CupertinoIcons.arrow_2_circlepath),
          );
        },
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColor.greenSecondary.withAlpha(120),
        foregroundColor: AppColor.greenPrimary,
        padding: const EdgeInsets.all(4),
        shape: const CircleBorder(),
        minimumSize: const Size(20, 20),
      ),
    );
  }
}
