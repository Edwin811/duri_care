import 'package:flutter/widgets.dart';

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}

List<OnboardingData> contentsList = [
  OnboardingData(
    title: 'Welcome to Duri Care',
    description: 'Your health, our priority.',
    imagePath: 'assets/images/onboarding1.png',
    backgroundColor: const Color(0xFFB2EBF2),
  ),
  OnboardingData(
    title: 'Track Your Health',
    description: 'Monitor your health with ease.',
    imagePath: 'assets/images/onboarding2.png',
    backgroundColor: const Color(0xFF80DEEA),
  ),
  OnboardingData(
    title: 'Stay Connected',
    description: 'Connect with healthcare professionals.',
    imagePath: 'assets/images/onboarding3.png',
    backgroundColor: const Color(0xFF4DD0E1),
  ),
];

