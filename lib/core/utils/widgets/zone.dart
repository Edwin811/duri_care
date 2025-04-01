import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';

class Zone extends StatefulWidget {
  const Zone({super.key});

  @override
  State<Zone> createState() => _ZoneState();
}

class _ZoneState extends State<Zone> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        // color: AppColor.greenPrimary,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
    );
  }
}