import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'zone_controller.dart';

class ZoneView extends GetView<ZoneController> {
  const ZoneView({super.key});
  static const String route = '/zone';

  @override
  Widget build(BuildContext context) {
    // Get the zoneId from route parameters
    final zoneId = Get.parameters['zoneId'];

    // Load zone data when entering the view
    if (zoneId != null && zoneId.isNotEmpty) {
      controller.loadZoneById(zoneId);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        Get.back(result: result);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(),
          title: Obx(
            () => Text(
              controller.selectedZone.isNotEmpty
                  ? controller.selectedZone['name'] ?? 'Zone Details'
                  : 'Zone Details',
              // style: AppThemes.textTheme(context, ColorScheme.dark()).titleLarge,
            ),
          ),
          actions: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Zone',
              onPressed: () {
                if (zoneId != null) {
                  Get.toNamed('/edit-zone', parameters: {'zoneId': zoneId});
                }
              },
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete Zone',
              onPressed: () {
                if (zoneId != null) {
                  controller.deleteZone(int.parse(zoneId));
                }
              },
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _buildStatusCard(context),
                          // const SizedBox(height: 24),
                          _buildIoTDevicesSection(context),
                          const SizedBox(height: 24),
                          _buildSchedulingSection(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.greenSecondary.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.grass, color: AppColor.greenPrimary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Zone Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Obx(
                  () => Switch(
                    value: controller.isActive.value,
                    onChanged: (value) {
                      final zoneId = controller.selectedZone['id']?.toString();
                      if (zoneId != null && zoneId.isNotEmpty) {
                        controller.toggleActive(zoneId);
                      }
                    },
                    activeTrackColor: AppColor.greenPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Obx(
                  () => _buildInfoItem(
                    context,
                    'Soil Moisture',
                    controller.moisture.value,
                    Icons.water_drop_outlined,
                  ),
                ),
                Obx(
                  () => _buildInfoItem(
                    context,
                    'Temperature',
                    controller.temperature.value,
                    Icons.thermostat,
                  ),
                ),
                Obx(
                  () => _buildInfoItem(
                    context,
                    'Humidity',
                    controller.humidity.value,
                    Icons.cloud,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildIoTDevicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perangkat IoT Terhubung',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              List<Map<String, dynamic>> devices = [
                {
                  'name': 'Soil Moisture Sensor',
                  'status': 'Online',
                  'battery': '85%',
                },
                {
                  'name': 'Water Valve Controller',
                  'status': 'Online',
                  'battery': '72%',
                },
                {
                  'name': 'Weather Station',
                  'status': 'Online',
                  'battery': '90%',
                },
              ];

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.sensors, color: Colors.white),
                ),
                title: Text(devices[index]['name']),
                subtitle: Text('Status: ${devices[index]['status']}'),
                trailing: Text(
                  '${devices[index]['battery']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Penyiraman Otomatis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Obx(
                  () => Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined),
                      const SizedBox(width: 8),
                      Text(
                        controller.selectedDate.value != null
                            ? DateFormat('dd MMMM yyyy').format(
                              controller.selectedDate.value ?? DateTime.now(),
                            )
                            : 'Select date',
                      ),
                      const Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColor.greenPrimary),
                        ),
                        onPressed: () => controller.selectDate(context),
                        child: const Text(
                          'Pilih',
                          style: TextStyle(color: AppColor.greenPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(
                        controller.selectedTime.value != null
                            ? '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}'
                            : 'Select time',
                      ),
                      const Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColor.greenPrimary),
                        ),
                        onPressed: () => controller.selectTime(context),
                        child: const Text(
                          'Pilih',
                          style: TextStyle(color: AppColor.greenPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.water),
                    const SizedBox(width: 8),
                    const Text('Durasi: '),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 8.0,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 10.0,
                          ),
                        ),
                        child: Obx(
                          () => Slider(
                            value: controller.duration.value.toDouble(),
                            min: 5,
                            max: 60,
                            divisions: 11,
                            label: '${controller.duration.value} mins',
                            onChanged: (value) {
                              controller.duration.value = value.toInt();
                            },
                            activeColor: AppColor.greenPrimary,
                            inactiveColor: AppColor.greenPrimary.withAlpha(100),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => Text('${controller.duration.value} mins')),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AppFilledButton(
                    onPressed: () => controller.saveSchedule(),
                    text: 'Simpan Jadwal',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Scheduled times list - updated to use actual schedules from database
        Text('Jadwal Tersimpan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingSchedules.value) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.schedules.isEmpty) {
            return Card(
              color: AppColor.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColor.greenPrimary.withAlpha(20)),
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
              final scheduledAt = DateTime.parse(schedule['scheduled_at']);
              final duration = schedule['duration'];

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
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Jam ${DateFormat('HH:mm').format(scheduledAt)} • Durasi $duration menit',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      controller.deleteSchedule(schedule['id']);
                    },
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
