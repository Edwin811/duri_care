import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CtaLink extends StatelessWidget {
  const CtaLink({super.key, required this.onPressed, required this.text, required this.linkText});
  final VoidCallback onPressed;
  final String text;
  final String linkText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: text,
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () {
                        onPressed();
                      },
                text: linkText,
                style: TextStyle(
                  color: AppColor.greenSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
