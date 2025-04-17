import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/iotDevice/iot_device.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';

class ZoneController extends GetxController {
  final supabase = Supabase.instance.client;
  final zones = <Map<String, dynamic>>[].obs;
  final selectedZone = <String, dynamic>{}.obs;
  final isActive = false.obs;
  final storage = GetStorage();

  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = Rx<String?>(null);
  final duration = 15.obs;
  final schedules = <Map<String, dynamic>>[].obs;

  final TextEditingController zoneNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RxBool isLoadingDevices = false.obs;
  final devices = <IoTDevice>[].obs;
  final selectedDeviceIds = <String>[].obs;
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    isActive.value = storage.read('isActive') ?? false;
    selectedDate.value = DateTime.now();
    selectedTime.value = '06:00';

    loadSchedules();
    loadDevices();
  }

  /// Mengambil data perangkat IoT dari server
  Future<void> loadDevices() async {
    isLoadingDevices.value = true;
    try {
      final response = await supabase
          .from('iot_devices')
          .select('*')
          .eq('owner_id', user?.id ?? '');

      if (response != null) {
        final List<IoTDevice> loadedDevices =
            (response as List)
                .map(
                  (device) => IoTDevice(
                    id: device['id'],
                    name: device['name'],
                    type: device['type'],
                    status: device['status'] ?? 'offline',
                  ),
                )
                .toList();

        devices.value = loadedDevices;
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Memuat Perangkat',
        'Gagal memuat perangkat IoT: ${e.toString()}',
      );
    } finally {
      isLoadingDevices.value = false;
    }
  }

  /// Menambah atau menghapus perangkat dari daftar perangkat yang dipilih
  void toggleDeviceSelection(String deviceId) {
    if (selectedDeviceIds.contains(deviceId)) {
      selectedDeviceIds.remove(deviceId);
    } else {
      selectedDeviceIds.add(deviceId);
    }
  }

  Future<void> createZone(String zoneName) async {
    if (!formKey.currentState!.validate()) return;

    final nameToUse = zoneNameController.text.trim();

    try {
      final response =
          await supabase.from('zones').insert({
            'name': nameToUse,
            'owner_id': supabase.auth.currentUser?.id,
            // 'device_count': selectedDeviceIds.length,
            'status': true,
            'created_at': DateTime.now().toIso8601String(),
          }).select();

      if (response != null && response.isNotEmpty) {
        final zoneId = response[0]['id'];

        // Menyimpan perangkat terpilih ke zona
        if (selectedDeviceIds.isNotEmpty) {
          await _assignDevicesToZone(zoneId);
        }

        zones.add(response[0]);
        Get.back();
        DialogHelper.showSuccessDialog(
          'Zona $nameToUse berhasil dibuat.',
          title: 'Zona Berhasil Dibuat',
        );
      }
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', e.toString());
    }
  }

  /// Menetapkan perangkat IoT terpilih ke sebuah zona
  Future<void> _assignDevicesToZone(String zoneId) async {
    try {
      final deviceAssignments =
          selectedDeviceIds
              .map(
                (deviceId) => {
                  'device_id': deviceId,
                  'zone_id': zoneId,
                  'assigned_at': DateTime.now().toIso8601String(),
                },
              )
              .toList();

      await supabase.from('zone_devices').insert(deviceAssignments);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Peringatan',
        'Zona berhasil dibuat tetapi gagal menambahkan beberapa perangkat: ${e.toString()}',
      );
    }
  }

  void deleteZone(String zoneId) async {
    try {
      final response = await supabase.from('zones').delete().eq('id', zoneId);
      if (response.error == null) {
        zones.removeWhere((zone) => zone['id'] == zoneId);
        DialogHelper.showSuccessDialog(
          'Zona berhasil dihapus.',
          title: 'Zona Dihapus',
        );
      } else {
        DialogHelper.showErrorDialog(
          response.error!.message,
          title: 'Gagal Menghapus Zona',
        );
      }
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', e.toString());
    }
  }

  void updateZone(String zoneId, String newZoneName) {
    try {
      supabase
          .from('zones')
          .update({'name': newZoneName})
          .eq('id', zoneId)
          .then((response) {
            if (response.error == null) {
              final index = zones.indexWhere((zone) => zone['id'] == zoneId);
              if (index != -1) {
                zones[index]['name'] = newZoneName;
                zones.refresh();
              }
              DialogHelper.showSuccessDialog(
                'Nama zona berhasil diperbarui.',
                title: 'Zona Diperbarui',
              );
            } else {
              DialogHelper.showErrorDialog(
                response.error!.message,
                title: 'Gagal Memperbarui Zona',
              );
            }
          });
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', e.toString());
    }
  }

  void toggleActive() {
    isActive.value = !isActive.value;
    storage.write('isActive', isActive.value);

    updateZoneStatus(isActive.value ? 'active' : 'inactive');
  }

  void updateZoneStatus(String status) {
    if (selectedZone.isEmpty || selectedZone['id'] == null) return;

    try {
      supabase
          .from('zones')
          .update({'status': status})
          .eq('id', selectedZone['id'])
          .then((response) {
            if (response.error != null) {
              DialogHelper.showErrorDialog(
                response.error!.message,
                title: 'Status Update Failed',
              );
            }
          });
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', e.toString());
    }
  }

  void saveSchedule() {
    if (selectedDate.value == null || selectedTime.value == null) {
      DialogHelper.showErrorDialog(
        title: 'Invalid Schedule',
        'Please select both date and time for the schedule.',
      );
      return;
    }

    final schedule = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': selectedDate.value!.toIso8601String(),
      'time': selectedTime.value,
      'duration': duration.value,
      'zone_id': selectedZone['id'] ?? '',
    };

    schedules.add(schedule);
    schedules.refresh();

    saveSchedulesToStorage();

    DialogHelper.showSuccessDialog(
      title: 'Schedule Saved',
      'Your irrigation schedule has been saved.',
    );
  }

  void deleteSchedule(String scheduleId) {
    schedules.removeWhere((schedule) => schedule['id'] == scheduleId);
    saveSchedulesToStorage();
  }

  void loadSchedules() {
    final String zoneId = selectedZone['id'] ?? '';
    if (zoneId.isEmpty) return;

    final List<dynamic>? savedSchedules = storage.read('schedules_$zoneId');
    if (savedSchedules != null) {
      schedules.value = List<Map<String, dynamic>>.from(savedSchedules);
    }
  }

  void saveSchedulesToStorage() {
    final String zoneId = selectedZone['id'] ?? '';
    if (zoneId.isEmpty) return;

    storage.write('schedules_$zoneId', schedules.toList());
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama zona tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama zona minimal 3 karakter';
    }
    return null;
  }
}
