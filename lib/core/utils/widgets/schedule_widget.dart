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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Responsive spacing
    final smallSpacing = isSmallScreen ? 6.0 : 8.0;
    final mediumSpacing = isSmallScreen ? 12.0 : 16.0;
    final cardPadding = isSmallScreen ? 12.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<bool>(
          future: controller.hasAutoSchedulePermission(),
          builder: (context, snapshot) {
            final hasPermission = snapshot.data ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasPermission) ...[
                  Text(
                    'Buat Jadwal Penyiraman Otomatis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: isSmallScreen ? 18 : null,
                    ),
                  ),
                  SizedBox(height: smallSpacing),
                  Card(
                    elevation: 0,
                    color: AppColor.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 12 : 16,
                      ),
                      side: BorderSide(color: AppColor.greenPrimary),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: buildScheduleFormContent(context),
                    ),
                  ),
                  SizedBox(height: mediumSpacing),
                ],
                Text(
                  'Jadwal Tersimpan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: isSmallScreen ? 18 : null,
                  ),
                ),
                SizedBox(height: smallSpacing),
                _buildSchedulesList(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildScheduleFormContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    final smallSpacing = isSmallScreen ? 6.0 : 8.0;
    final mediumSpacing = isSmallScreen ? 12.0 : 16.0;
    final buttonHeight = isSmallScreen ? 36.0 : 40.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    return Column(
      children: [
        Obx(
          () =>
              isSmallScreen
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          SizedBox(width: smallSpacing),
                          Expanded(
                            child: Text(
                              controller.selectedDate.value != null
                                  ? DateFormat(
                                    'dd MMMM yyyy',
                                  ).format(controller.selectedDate.value!)
                                  : 'Pilih tanggal',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: smallSpacing),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColor.greenPrimary),
                          ),
                          onPressed: () => controller.selectDate(context),
                          child: Text(
                            'Pilih Tanggal',
                            style: TextStyle(
                              color: AppColor.greenPrimary,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 20),
                      SizedBox(width: smallSpacing),
                      Text(
                        controller.selectedDate.value != null
                            ? DateFormat(
                              'dd MMMM yyyy',
                            ).format(controller.selectedDate.value!)
                            : 'Pilih tanggal',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColor.greenPrimary),
                        ),
                        onPressed: () => controller.selectDate(context),
                        child: Text(
                          'Pilih',
                          style: TextStyle(
                            color: AppColor.greenPrimary,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
        SizedBox(height: smallSpacing),

        Obx(
          () =>
              isSmallScreen
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          SizedBox(width: smallSpacing),
                          Expanded(
                            child: Text(
                              controller.selectedTime.value != null
                                  ? '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}'
                                  : 'Pilih waktu',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: smallSpacing),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColor.greenPrimary),
                          ),
                          onPressed: () => controller.selectTime(context),
                          child: Text(
                            'Pilih Waktu',
                            style: TextStyle(
                              color: AppColor.greenPrimary,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Icon(Icons.access_time, size: 20),
                      SizedBox(width: smallSpacing),
                      Text(
                        controller.selectedTime.value != null
                            ? '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}'
                            : 'Pilih waktu',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColor.greenPrimary),
                        ),
                        onPressed: () => controller.selectTime(context),
                        child: Text(
                          'Pilih',
                          style: TextStyle(
                            color: AppColor.greenPrimary,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
        SizedBox(height: smallSpacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water, size: isSmallScreen ? 18 : 20),
                SizedBox(width: smallSpacing),
                Text('Durasi: ', style: TextStyle(fontSize: fontSize)),
              ],
            ),
            SizedBox(height: smallSpacing),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: isSmallScreen ? 6.0 : 8.0,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: isSmallScreen ? 8.0 : 10.0,
                      ),
                    ),
                    child: Obx(
                      () => Slider(
                        value: controller.durationIrg.value.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        label: '${controller.durationIrg.value} menit',
                        onChanged: (value) {
                          controller.durationIrg.value = value.toInt();
                        },
                        activeColor: AppColor.greenPrimary,
                        inactiveColor: AppColor.greenPrimary.withAlpha(100),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: smallSpacing),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 10,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.greenPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Obx(
                    () => Text(
                      '${controller.durationIrg.value} menit',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: mediumSpacing),
        SizedBox(
          width: double.infinity,
          height: isSmallScreen ? 44 : 48,
          child: AppFilledButton(
            onPressed: () => controller.saveSchedule(),
            text: 'Simpan Jadwal',
            textSize: fontSize.toInt(),
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulesList() {
    final screenWidth =
        Get.context != null ? MediaQuery.of(Get.context!).size.width : 400.0;
    final isSmallScreen = screenWidth < 360;

    return Obx(() {
      if (controller.isLoadingSchedules.value) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            side: BorderSide(color: AppColor.greenPrimary.withAlpha(120)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 20 : 30,
              horizontal: isSmallScreen ? 16 : 20,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: AppColor.greenPrimary.withValues(alpha: 0.6),
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memuat jadwal...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mohon tunggu sebentar',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.black54,
                        ),
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
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            side: BorderSide(color: AppColor.greenPrimary.withAlpha(120)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 16 : 20,
            ),
            leading: Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: isSmallScreen ? 20 : 24,
            ),
            title: Text(
              'Tidak ada jadwal aktif',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            subtitle: Text(
              'Buatlah jadwal penyiraman otomatis terlebih dahulu. Jadwal yang sudah dieksekusi akan dihapus secara otomatis.',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.schedules.length,
        separatorBuilder:
            (context, index) => SizedBox(height: isSmallScreen ? 8 : 12),
        itemBuilder: (context, index) {
          final schedule = controller.schedules[index];
          final scheduledAt = DateTime.parse(
            schedule.schedule.scheduledAt.toString(),
          );
          final duration = schedule.schedule.duration;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              side: BorderSide(color: AppColor.greenPrimary.withAlpha(150)),
            ),
            color: AppColor.white,
            child:
                isSmallScreen
                    ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColor.greenPrimary,
                                radius: 16,
                                child: const Icon(
                                  Icons.water_drop,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd MMMM yyyy',
                                  ).format(scheduledAt),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              FutureBuilder<bool>(
                                future: controller.hasAutoSchedulePermission(),
                                builder: (context, snapshot) {
                                  final hasPermission = snapshot.data ?? false;
                                  if (!hasPermission)
                                    return const SizedBox.shrink();

                                  return IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      controller.deleteSchedule(
                                        schedule.schedule.id,
                                        schedule.zoneId,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 44),
                            child: Text(
                              'Jam ${DateFormat('HH:mm').format(scheduledAt)} | Durasi $duration menit',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColor.greenPrimary,
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        DateFormat('dd MMMM yyyy').format(scheduledAt),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Jam ${DateFormat('HH:mm').format(scheduledAt)} | Durasi $duration menit',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: FutureBuilder<bool>(
                        future: controller.hasAutoSchedulePermission(),
                        builder: (context, snapshot) {
                          final hasPermission = snapshot.data ?? false;
                          if (!hasPermission) return const SizedBox.shrink();

                          return IconButton(
                            icon: Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.red,
                              size: isSmallScreen ? 28 : 32,
                            ),
                            onPressed: () {
                              controller.deleteSchedule(
                                schedule.schedule.id,
                                schedule.zoneId,
                              );
                            },
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
