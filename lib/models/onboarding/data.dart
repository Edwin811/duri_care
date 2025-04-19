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
    title: 'Selamat Datang di Duri Care',
    description: 'Solusi cerdas untuk kebun durian Anda dengan irigasi otomatis berbasis IoT.',
    imagePath: 'assets/images/onboarding-1.png',
  ),
  OnboardingData(
    title: 'Minimalkan Risiko Gagal Panen',
    description: 'Pantau kondisi kebun dan kelola irigasi secara otomatis untuk hasil panen maksimal.',
    imagePath: 'assets/images/onboarding-2.png',
  ),
  OnboardingData(
    title: 'Kontrol Mudah dari Mana Saja',
    description: 'Atur dan awasi sistem irigasi kebun durian Anda langsung dari aplikasi.',
    imagePath: 'assets/images/onboarding-3.png',
  ),
  OnboardingData(
    title: 'Mulai Tingkatkan Produktivitas',
    description: 'Gabung bersama Duri Care dan wujudkan kebun durian yang lebih sehat dan produktif.',
    imagePath: 'assets/images/onboarding-4.png',
  ),
];

List<Widget> get onboardingPages =>
    contentsList.map((data) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
