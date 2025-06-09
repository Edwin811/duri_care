import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditZoneView extends GetView<ZoneController> {
  const EditZoneView({super.key});
  static const String route = '/edit-zone';
  @override
  Widget build(BuildContext context) {
    final zoneId = Get.parameters['zoneId'] ?? '';

    if (controller.selectedZone.isNotEmpty) {
      controller.zoneNameController.text =
          controller.selectedZone['name'] ?? '';
      controller.selectedZoneCode.value =
          controller.selectedZone['zone_code'] ?? 1;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(iconColor: AppColor.white),
          title: Text(
            'Edit Zona',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(color: AppColor.white),
          ),
          backgroundColor: AppColor.greenPrimary,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
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
                            (value) => controller.validateName(
                              value ?? '',
                              excludeZoneId: zoneId,
                            ),
                        prefixIcon: Icons.note_alt_outlined,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode Zona',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField(
                        value:
                            controller.selectedZone['zone_code'] ??
                            controller.selectedZoneCode.value,
                        items:
                            controller.zoneCodes.map((zoneCode) {
                              return DropdownMenuItem<int>(
                                value: zoneCode,
                                child: Text('$zoneCode'),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedZoneCode.value = value as int;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Pilih kode zona',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: const Icon(Icons.code),
                        ),
                      ),
                    ),
                  ],
                ),
                AppFilledButton(
                  onPressed: () {
                    if (controller.formKey.currentState?.validate() == true &&
                        zoneId.isNotEmpty) {
                      controller.updateZone(
                        zoneId,
                        newName: controller.zoneNameController.text,
                      );
                    }
                  },
                  text: 'Simpan Perubahan',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
