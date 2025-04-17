import 'package:duri_care/core/utils/widgets/zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:duri_care/features/zone/zone_controller.dart';

class ZoneGrid extends GetView<ZoneController> {
  const ZoneGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final totalZones = controller.zones.length;
    // final totalZones = 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildZoneContent(totalZones)],
    );
  }

  Widget _buildZoneContent(int totalZones) {
    final context = Get.context!;
    if (totalZones == 0) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            SvgPicture.asset(
              'assets/images/No-Data.svg',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Text(
                'Belum ada zona yang ditambahkan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Text(
                'Silahkan tambahkan zona baru dengan menekan tombol "Tambah" di bawah',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: totalZones,
      itemBuilder: (_, __) => const Zone(),
    );
  }
}
