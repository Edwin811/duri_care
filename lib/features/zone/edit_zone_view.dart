import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditZoneView extends GetView<ZoneController> {
  const EditZoneView({super.key});
  static const String route = '/edit-zone';

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final zoneId = Get.parameters['zoneId'] ?? '';

    // Set initial value from selected zone
    if (controller.selectedZone.isNotEmpty) {
      nameController.text = controller.selectedZone['name'] ?? '';
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(),
          title: Text(
            'Edit Zona',
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
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Zona',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AppTextFormField(
                        controller: nameController,
                        hintText: 'Masukkan nama zona',
                        validator:
                            (value) => controller.validateName(value ?? ''),
                        prefixIcon: Icons.note_alt_outlined,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isLoading.value
                              ? null
                              : () async {
                                if (formKey.currentState!.validate() &&
                                    zoneId.isNotEmpty) {
                                  await controller.updateZone(
                                    zoneId,
                                    newName: nameController.text,
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.greenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          controller.isLoading.value
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Simpan Perubahan',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
