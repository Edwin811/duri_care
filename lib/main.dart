import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const DuriCare());
}

class DuriCare extends StatelessWidget {
  const DuriCare({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DuriCare',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      // home: const HomePage(),
    );
  }
}