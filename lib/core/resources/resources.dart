import 'package:flutter/material.dart';

abstract class AppColor {
  static const white = Colors.white;
  static const greenPrimary = Color(0xFF093731);
  static const greenSecondary = Color(0xFF00A558);
  static const greenTertiary = Color(0xFFC1FF72);
  static const yellowPrimary = Color(0xFFF3B81E);
  static const lavenderPrimary = Color(0xFF8177EA);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

abstract class AppSpacing {
  static const xs = SizedBox(height: 4);
  static const sm = SizedBox(height: 8);
  static const md = SizedBox(height: 12);
  static const lg = SizedBox(height: 16);
  static const xl = SizedBox(height: 24);
  static const xxl = SizedBox(height: 32);
  static const xxxl = SizedBox(height: 40);
  static const xxxxl = SizedBox(height: 48);
  static const xxxxxl = SizedBox(height: 64);
}
