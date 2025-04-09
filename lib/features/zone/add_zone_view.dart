import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddZoneView extends GetView<ZoneController> {
  const AddZoneView({super.key});
  static const String route = '/add-zone';

  @override
  Widget build(BuildContext context) {
    final TextEditingController zoneNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(),
        title: Text(
          'Tambah Zona Baru',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone name input
              Text('Nama Zona', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: zoneNameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kebun Depan, Taman Belakang, dll',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              const SizedBox(height: 24),

              // Zone type selection
              Text('Tipe Zona', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildZoneTypeSelector(context),

              const SizedBox(height: 24),

              // IoT device selection
              Text(
                'Tambahkan Perangkat IoT',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildIoTDevicesList(context),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (zoneNameController.text.isNotEmpty) {
                      controller.createZone(zoneNameController.text);
                      Get.back();
                    } else {
                      Get.snackbar(
                        'Error',
                        'Nama zona tidak boleh kosong',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.greenPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Simpan Zona',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneTypeSelector(BuildContext context) {
    List<Map<String, dynamic>> zoneTypes = [
      {'name': 'Kebun', 'icon': Icons.grass_outlined},
      {'name': 'Taman', 'icon': Icons.park_outlined},
      {'name': 'Halaman', 'icon': Icons.yard_outlined},
      {'name': 'Lainnya', 'icon': Icons.more_horiz},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: zoneTypes.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  zoneTypes[index]['icon'],
                  size: 32,
                  color: AppColor.greenPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  zoneTypes[index]['name'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIoTDevicesList(BuildContext context) {
    List<Map<String, dynamic>> devices = [
      {
        'name': 'Sensor Kelembaban Tanah',
        'icon': Icons.water_drop_outlined,
        'isConnected': false,
      },
      {
        'name': 'Kontrol Katup Air',
        'icon': Icons.settings_input_component_outlined,
        'isConnected': false,
      },
      {
        'name': 'Sensor Cuaca',
        'icon': Icons.cloud_outlined,
        'isConnected': false,
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColor.greenPrimary.withAlpha(80),
              child: Icon(devices[index]['icon'], color: AppColor.greenPrimary),
            ),
            title: Text(devices[index]['name']),
            trailing: Switch(
              value: devices[index]['isConnected'],
              activeColor: AppColor.greenPrimary,
              onChanged: (bool value) {
                // In a real app, you would update the controller here
                devices[index]['isConnected'] = value;
              },
            ),
          );
        },
      ),
    );
  }
}
