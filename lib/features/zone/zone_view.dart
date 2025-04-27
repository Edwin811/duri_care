import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/themes/app_themes.dart';
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
    final zoneId = Get.parameters['zoneId'];

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
          backgroundColor: AppColor.greenPrimary,
          leading: AppBackButton(
            iconColor: AppColor.white,
          ),
          title: Obx(
            () => Text(
              controller.selectedZone.isNotEmpty
                  ? controller.selectedZone['name'] ?? 'Zone Details'
                  : 'Zone Details',
              style:
                  AppThemes.textTheme(context, ColorScheme.dark()).titleLarge,
            ),
          ),
          actions: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColor.white,),
              tooltip: 'Edit Zone',
              onPressed: () {
                if (zoneId != null) {
                  Get.toNamed('/edit-zone', parameters: {'zoneId': zoneId});
                }
              },
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColor.redOff),
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
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingDevices.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.devices.isEmpty) {
            return Card(
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[500]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(34),
                child: Column(
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada perangkat IoT terhubung',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan perangkat IoT untuk memonitor zona ini',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.devices.length,
            itemBuilder: (context, index) {
              final device = controller.devices[index];

              IconData deviceIcon = Icons.sensors;
              if (device.type == 'moisture_sensor') {
                deviceIcon = Icons.water_drop;
              } else if (device.type == 'valve_controller') {
                deviceIcon = Icons.device_hub_outlined;
              } else if (device.type == 'weather_station') {
                deviceIcon = Icons.cloud;
              }

              Color statusColor = Colors.grey;
              if (device.status == 'online') {
                statusColor = Colors.green;
              } else if (device.status == 'offline') {
                statusColor = Colors.red;
              } else if (device.status == 'warning') {
                statusColor = Colors.orange;
              }

              final batteryLevel = 60 + (index * 10) % 40;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColor.greenSecondary.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              deviceIcon,
                              color: AppColor.greenPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      device.status.capitalize!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.battery_full,
                                    color:
                                        batteryLevel > 20
                                            ? AppColor.greenPrimary
                                            : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$batteryLevel%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 100,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: batteryLevel.toDouble(),
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color:
                                            batteryLevel > 20
                                                ? AppColor.greenPrimary
                                                : Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (index < controller.devices.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Divider(height: 1),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSchedulingSection(BuildContext context) {
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
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                      size: 32,
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
