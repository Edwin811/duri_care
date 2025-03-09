import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';

class AppLabelText extends StatelessWidget {
  const AppLabelText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.textPrimary,
          ),
        ),
      ),
    );
  }
}