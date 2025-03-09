import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';

class SplashscreenView extends StatelessWidget{
  const SplashscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greenPrimary,
      body: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/images/logo/LOGO-AGRITECH.png', width: 120),
            Text(
              'DuriCare',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}