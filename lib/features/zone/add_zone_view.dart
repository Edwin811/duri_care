import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddZoneView extends GetView<ZoneController> {
  const AddZoneView({super.key});
  static const String route = '/add-zone';

  @override
  Widget build(BuildContext context) {
    final TextEditingController zoneNameController = TextEditingController();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Zona',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AppTextFormField(
                        controller: controller.zoneNameController,
                        hintText: 'Masukkan nama zona',
                        validator:
                            (value) => controller.validateName(value ?? ''),
                        prefixIcon: Icons.note_alt_outlined,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                      controller.createZone(zoneNameController.text.trim());
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
      ),
    );
  }

  Widget _buildIoTDevicesList(BuildContext context) {
    return Obx(() => controller.isLoadingDevices.value
        ? const Center(child: CircularProgressIndicator())
        : controller.devices.isEmpty
            ? Center(
                child: Text(
                  'Tidak ada perangkat IoT yang tersedia',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.devices.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final device = controller.devices[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColor.greenPrimary.withAlpha(80),
                        child: Icon(_getDeviceIcon(device.type), color: AppColor.greenPrimary),
                      ),
                      title: Text(device.name),
                      subtitle: Text(device.status),
                      trailing: Switch(
                        value: controller.selectedDeviceIds.contains(device.id),
                        activeColor: AppColor.greenPrimary,
                        onChanged: (bool value) {
                          controller.toggleDeviceSelection(device.id);
                        },
                      ),
                    );
                  },
                ),
              ));
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'moisture_sensor':
        return Icons.water_drop_outlined;
      case 'valve_control':
        return Icons.settings_input_component_outlined;
      case 'weather_sensor':
        return Icons.cloud_outlined;
      default:
        return Icons.devices_other;
    }
  }
}
