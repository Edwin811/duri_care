import 'package:flutter/widgets.dart';

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

List<OnboardingData> contentsList = [
  OnboardingData(
    title: 'Welcome to Duri Care',
    description: 'Your health, our priority.',
    imagePath: 'assets/images/onboarding-1.png', 
  ),
  OnboardingData(
    title: 'Track Your Health',
    description: 'Monitor your health with ease.',
    imagePath: 'assets/images/onboarding-2.png',
  ),
  OnboardingData(
    title: 'Stay Connected',
    description: 'Connect with healthcare professionals.',
    imagePath: 'assets/images/onboarding-3.png',
  ),
  OnboardingData(
    title: 'Get Started',
    description: 'Join us on this journey to better health.',
    imagePath: 'assets/images/onboarding-4.png',
  ),
];

List<Widget> get onboardingPages =>
    contentsList.map((data) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(data.imagePath),
          const SizedBox(height: 20),
          Text(
            data.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      );
    }).toList();
