import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SchedulingSectionWidget extends StatelessWidget {
  final ZoneController controller;

  const SchedulingSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Jadwal Penyiraman Otomatis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColor.greenPrimary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Gunakan FutureBuilder dengan method dari controller
                FutureBuilder<bool>(
                  future: controller.hasAutoSchedulePermission(),
                  builder: (context, snapshot) {
                    final hasPermission = snapshot.data ?? false;

                    if (!hasPermission) {
                      // Ambil widget dari controller
                      return controller.buildNoPermissionWidget();
                    }

                    // Ambil form content dari controller
                    return controller.buildScheduleFormContent(context);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Jadwal Tersimpan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _buildSchedulesList(),
      ],
    );
  }

  Widget _buildSchedulesList() {
    return Obx(() {
      if (controller.isLoadingSchedules.value) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColor.greenPrimary.withAlpha(120)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: AppColor.greenPrimary.withValues(alpha: 0.6),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Memuat jadwal...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mohon tunggu sebentar',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.schedules.isEmpty) {
        return Card(
          color: AppColor.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColor.greenPrimary.withAlpha(120)),
          ),
          child: const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.grey),
            title: Text(
              'Tidak ada jadwal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Buatlah jadwal penyiraman otomatis terlebih dahulu.',
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.schedules.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final schedule = controller.schedules[index];
          final scheduledAt = DateTime.parse(
            schedule.schedule.scheduledAt.toString(),
          );
          final duration = schedule.schedule.duration;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColor.greenPrimary.withAlpha(150)),
            ),
            color: AppColor.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColor.greenPrimary,
                child: const Icon(Icons.water_drop, color: Colors.white),
              ),
              title: Text(
                DateFormat('dd MMMM yyyy').format(scheduledAt),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Jam ${DateFormat('HH:mm').format(scheduledAt)} | Durasi $duration menit',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 32,
                ),
                onPressed: () {
                  controller.deleteSchedule(
                    schedule.schedule.id,
                    schedule.zoneId,
                  );
                },
              ),
            ),
          );
        },
      );
    });
  }
}
