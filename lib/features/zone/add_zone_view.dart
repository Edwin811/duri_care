import 'dart:ffi';

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
                // Zone code selection
                Text(
                  'Kode Zona',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '*Kode Zona digunakan untuk mengidentifikasi kode pada alat IoT',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Obx(
                      () => DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedZoneCode.value.toString(),
                        items:
                            controller.zoneCodes.map((int zoneCode) {
                              return DropdownMenuItem<String>(
                                value: zoneCode.toString(),
                                child: Text(zoneCode.toString()),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedZoneCode.value = int.parse(
                              newValue,
                            );
                          }
                        },
                        hint: const Text('Pilih Kode Zona'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.formKey.currentState!.validate()) {
                        await controller.createZone();
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
      ),
    );
  }
}
