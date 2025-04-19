import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/iotDevice/iot_device.dart';
import 'package:duri_care/models/zone/zone_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';

class ZoneController extends GetxController {
  final supabase = Supabase.instance.client;
  final zones = <Map<String, dynamic>>[].obs;
  final selectedZone = <String, dynamic>{}.obs;
  final isActive = false.obs;
  final storage = GetStorage();

  final timer = '00:00:00'.obs;
  Timer? _countdownTimer;

  final selectedDate = Rx<DateTime?>(DateTime.now());
  final selectedTime = Rx<TimeOfDay?>(const TimeOfDay(hour: 6, minute: 0));
  final duration = RxInt(5);
  final schedules = <Map<String, dynamic>>[].obs;

  final TextEditingController zoneNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RxBool isLoadingDevices = false.obs;
  final devices = <IoTDevice>[].obs;
  final selectedDeviceIds = <int>[].obs;
  final userId = Supabase.instance.client.auth.currentUser?.id;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    isActive.value = storage.read('isActive') ?? false;
    selectedDate.value = DateTime.now();
    selectedTime.value = const TimeOfDay(hour: 6, minute: 0);

    loadZones();
    loadSchedules();
    loadDevices();
  }

  /// Loads all zones for the current user
  Future<void> loadZones() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        DialogHelper.showErrorDialog(
          title: 'Authentication Error',
          'User not logged in. Please log in to view your zones.',
        );
        return;
      }

      final response = await supabase
          .from('zones')
          .select('*, zone_users!inner(*)')
          .eq('zone_users.user_id', userId)
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> zonesList = [];

      for (var item in response) {
        Map<String, dynamic> zoneMap = {};
        item.forEach((key, value) {
          zoneMap[key.toString()] = value;
        });

        zoneMap['timer'] = '00:00:00';
        zoneMap['moisture'] = '60%';

        zonesList.add(zoneMap);
      }

      zones.value = zonesList;
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Zones',
        'Error: ${e.toString()}',
      );
    }
  }

  /// Loads a specific zone by ID
  Future<void> loadZoneById(int zoneId) async {
    isLoading.value = true;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        DialogHelper.showErrorDialog(
          title: 'Authentication Error',
          'User not logged in. Please log in to view your zones.',
        );
        isLoading.value = false;
        return;
      }

      final response =
          await supabase
              .from('zones')
              .select('*, zone_users!inner(*)')
              .eq('id', zoneId)
              .eq('zone_users.user_id', userId)
              .single();

      Map<String, dynamic> zoneMap = {};
      response.forEach((key, value) {
        zoneMap[key.toString()] = value;
      });

      zoneMap['timer'] = '00:00:00';
      zoneMap['moisture'] = '60%';

      selectedZone.value = zoneMap;
      loadSchedules();

      // Also update isActive status based on selected zone
      isActive.value = zoneMap['isActive'] ?? false;
      storage.write('isActive', isActive.value);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Zone',
        'Error: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Mengambil data perangkat IoT dari server
  Future<void> loadDevices() async {
    isLoadingDevices.value = true;
    try {
      final response = await supabase
          .from('iot_devices')
          .select(
            '*, zones!inner(id, name, isActive, created_at, zone_users!inner(user_id))',
          )
          .eq('zones.zone_users.user_id', userId ?? '')
          .order('id', ascending: true);

      final List<IoTDevice> loadedDevices =
          (response as List).map((device) {
            final zoneData = device['zone'];

            return IoTDevice(
              id: device['id'],
              name: device['name'],
              type: device['type'],
              status: device['status'] ?? 'offline',
              zone: ZoneModel(
                id: zoneData['id'],
                name: zoneData['name'],
                isActive: zoneData['isActive'] ?? false,
                createdAt: DateTime.parse(zoneData['created_at']),
              ),
            );
          }).toList();

      devices.value = loadedDevices;
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
  void toggleDeviceSelection(int deviceId) {
    if (selectedDeviceIds.contains(deviceId)) {
      selectedDeviceIds.remove(deviceId);
    } else {
      selectedDeviceIds.add(deviceId);
    }
  }

  Future<void> createZone() async {
    final userId = supabase.auth.currentUser?.id;
    final name = zoneNameController.text.trim();
    if (userId == null || name.isEmpty) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        'User belum login atau nama zona kosong.',
      );
      return;
    }

    try {
      final existing =
          await supabase
              .from('zones')
              .select('id')
              .eq('name', name)
              .maybeSingle();

      if (existing != null) {
        DialogHelper.showErrorDialog(
          title: 'Nama Zona Sudah Ada',
          'Zona dengan nama "$name" sudah terdaftar. Silakan gunakan nama lain.',
        );
        return;
      }

      final newZone =
          await supabase
              .from('zones')
              .insert({
                'name': name,
                'isActive': false,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      final zoneId = newZone['id'];

      await supabase.from('zone_users').insert({
        'zone_id': zoneId,
        'user_id': userId,
        'assigned_at': DateTime.now().toIso8601String(),
      });

      if (selectedDeviceIds.isNotEmpty) {
        await _assignDevicesToZone(zoneId);
      }

      zones.add(newZone);
      await DialogHelper.showSuccessDialog(
        '$name berhasil dibuat.',
        title: 'Berhasil',
      );
      zoneNameController.clear();
      Get.back();
    } catch (e) {
      if (e.toString().contains('duplicate key value') ||
          e.toString().contains('unique constraint')) {
        DialogHelper.showErrorDialog(
          title: 'Nama Zona Sudah Ada',
          'Zona dengan nama "$name" sudah ada. Silakan gunakan nama lain.',
        );
      } else {
        DialogHelper.showErrorDialog(title: 'Gagal membuat zona', e.toString());
      }
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

  Future<void> deleteZone(int zoneId) async {
    try {
      await supabase.from('zone_users').delete().eq('zone_id', zoneId);
      await supabase.from('zones').delete().eq('id', zoneId);
      zones.removeWhere((z) => z['id'] == zoneId);
      DialogHelper.showSuccessDialog('Zona berhasil dihapus.');
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Gagal hapus zona', e.toString());
    }
  }

  Future<void> updateZone(int zoneId, {String? newName}) async {
    final data = <String, dynamic>{};

    if (newName != null) data['name'] = newName.trim();

    if (data.isEmpty) return;

    try {
      final updated =
          await supabase
              .from('zones')
              .update(data)
              .eq('id', zoneId)
              .select()
              .single();

      final index = zones.indexWhere((z) => z['id'] == zoneId);
      if (index != -1) zones[index] = updated;

      DialogHelper.showSuccessDialog('Zona berhasil diperbarui.');
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Gagal update', e.toString());
    }
  }

  void toggleActive() {
    isActive.value = !isActive.value;
    storage.write('isActive', isActive.value);

    updateZoneStatus(isActive.value);

    if (isActive.value) {
      startTimer();
    } else {
      stopTimer();
    }
  }

  void updateZoneStatus(bool newStatus) async {
    if (selectedZone.isEmpty || selectedZone['id'] == null) return;

    final zoneId = selectedZone['id'];

    try {
      final updatedZone =
          await supabase
              .from('zones')
              .update({'isActive': newStatus})
              .eq('id', zoneId)
              .select()
              .single();

      selectedZone['isActive'] = updatedZone['isActive'];

      final index = zones.indexWhere((z) => z['id'] == zoneId);
      if (index != -1) {
        zones[index] = updatedZone;
      }

      DialogHelper.showSuccessDialog('Status zona berhasil diperbarui.');
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', e.toString());
    }
  }

  Future<void> startTimer() async {
    int totalSeconds = 300;
    updateZoneStatus(true);

    final zoneId = selectedZone['id'];
    if (zoneId != null) {
      try {
        final latestSchedule =
            await supabase
                .from('schedules')
                .select('duration_minutes')
                .eq('zone_id', zoneId)
                .order('scheduled_at', ascending: false)
                .limit(1)
                .maybeSingle();

        if (latestSchedule != null &&
            latestSchedule['duration_minutes'] != null) {
          totalSeconds = (latestSchedule['duration_minutes'] as int) * 60;
        }
      } catch (e) {
        DialogHelper.showErrorDialog(
          title: 'Gagal Memuat Jadwal',
          'Durasi gagal diambil: ${e.toString()}',
        );
        return;
      }
    }

    _countdownTimer?.cancel();

    const oneSecond = Duration(seconds: 1);
    _countdownTimer = Timer.periodic(oneSecond, (timer) {
      if (totalSeconds > 0) {
        totalSeconds--;
        final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
        final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(
          2,
          '0',
        );
        final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
        this.timer.value = '$hours:$minutes:$seconds';
      } else {
        stopTimer();
        isActive.value = false;
        updateZoneStatus(false);
      }
    });
  }

  void stopTimer() {
    _countdownTimer?.cancel();
    timer.value = '00:00:00';
  }

  Future<void> saveSchedule() async {
    if (selectedDate.value == null || selectedTime.value == null) {
      DialogHelper.showErrorDialog(
        title: 'Invalid Schedule',
        'Please select both date and time for the schedule.',
      );
      return;
    }

    final zoneId = selectedZone['id'];
    if (zoneId == null) {
      DialogHelper.showErrorDialog(
        title: 'No Zone Selected',
        'Please select a zone.',
      );
      return;
    }

    final time = selectedTime.value!;
    final combinedDateTime = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      time.hour,
      time.minute,
    );

    try {
      final inserted =
          await supabase
              .from('schedules')
              .insert({
                'zone_id': zoneId,
                'scheduled_at': combinedDateTime.toIso8601String(),
                'duration_minutes': duration.value,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      schedules.add(inserted);
      DialogHelper.showSuccessDialog(
        title: 'Schedule Saved',
        'Your irrigation schedule has been saved.',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Save Schedule',
        e.toString(),
      );
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await supabase.from('schedules').delete().eq('id', scheduleId);
      schedules.removeWhere((schedule) => schedule['id'] == scheduleId);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Delete Schedule',
        e.toString(),
      );
    }
  }

  Future<void> loadSchedules() async {
    final zoneId = selectedZone['id'];
    if (zoneId == null) return;

    try {
      final data = await supabase
          .from('schedules')
          .select()
          .eq('zone_id', zoneId)
          .order('scheduled_at', ascending: true);

      schedules.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Schedules',
        e.toString(),
      );
    }
  }

  void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
    }
  }

  void selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedTime.value = pickedTime;
    }
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

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
