import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBackButton extends StatelessWidget {
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final IconData icon;
  final double iconSize;
  final EdgeInsets containerPadding;
  final Color? iconColor;
  final Color? borderColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back_ios_rounded,
    this.iconSize = 24,
    this.containerPadding = const EdgeInsets.all(8),
    this.style,
    this.iconColor,
    this.borderColor,
  });

  static ButtonStyle defaultStyle({
    Color borderColor = Colors.grey,
    double borderWidth = 1.0,
    double borderRadius = 8.0,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return IconButton.styleFrom(
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle effectiveStyle;
    
    if (borderColor != null && style == null) {
      effectiveStyle = defaultStyle(borderColor: borderColor!);
    } else {
      effectiveStyle = style ?? defaultStyle();
    }

    return Padding(
      padding: containerPadding,
      child: IconButton(
        onPressed: onPressed ?? () => Get.back(),
        icon: Icon(icon, size: iconSize, color: iconColor),
        style: effectiveStyle,
      ),
    );
  }
}
