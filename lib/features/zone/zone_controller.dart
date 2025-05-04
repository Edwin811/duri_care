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
  final RxBool isActive = false.obs;
  final storage = GetStorage();
  final RxInt activeCount = 0.obs;
  final RxBool isLoadingSchedules = false.obs;
  final Map<int, Timer> _scheduleTimers = {};

  final zoneCodes = [1, 2, 3, 4, 5, 6, 7, 8].obs;
  final RxInt selectedZoneCode = 1.obs;

  final Map<String, Timer?> _zoneTimers = {};
  final RxMap<String, RxString> zoneTimers = <String, RxString>{}.obs;

  final RxString moisture = '0%'.obs;
  final RxString temperature = '0°C'.obs;
  final RxString humidity = '0%'.obs;

  final selectedDate = Rx<DateTime?>(DateTime.now());
  final selectedTime = Rx<TimeOfDay?>(const TimeOfDay(hour: 6, minute: 0));
  final duration = 5.obs;
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

    loadZones().then((_) {
      _setupZoneTimers();
      listenToZoneChanges();
      countActive();
      loadAllZoneSchedules();
    });

    loadSchedules();
    loadDevices();
  }

  void _setupZoneTimers() {
    for (var zone in zones) {
      final zoneId = zone['id']?.toString();
      if (zoneId != null) {
        zoneTimers.putIfAbsent(zoneId, () => '00:00:00'.obs);

        if (zone['isActive'] == true) {
          startTimer(zoneId, duration.value);
        }

        final remainingTime = storage.read('timer_$zoneId');
        if (remainingTime != null && remainingTime > 0) {
          startTimer(zoneId, duration.value);
        }
      }
    }
  }

  /// Loads all zones for the current user
  Future<void> loadZones() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        DialogHelper.showErrorDialog(
          title: 'Authentication Error',
          message: 'User not logged in. Please log in to view your zones.',
        );
        return;
      }

      final response = await supabase
          .from('zones')
          .select('*, zone_users!inner(*)')
          .eq('zone_users.user_id', userId)
          .filter('deleted_at', 'is', 'null')
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> zonesList = [];

      for (var item in response) {
        Map<String, dynamic> zoneMap = Map<String, dynamic>.from(item);
        zoneMap['timer'] = '00:00:00';
        zoneMap['moisture'] = '60%';
        zonesList.add(zoneMap);
      }

      zones.value = zonesList;
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Zones',
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Loads a specific zone by ID
  Future<void> loadZoneById(String zoneId) async {
    if (zoneId.isEmpty) return;

    isLoading.value = true;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        DialogHelper.showErrorDialog(
          title: 'Authentication Error',
          message: 'User not logged in. Please log in to view your zones.',
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
              .filter('deleted_at', 'is', null)
              .single();

      Map<String, dynamic> zoneMap = Map<String, dynamic>.from(response);
      zoneMap['timer'] = zoneTimers[zoneId]?.value ?? '00:00:00';
      zoneMap['moisture'] = '60%';

      selectedZone.value = zoneMap;
      loadSchedules();

      isActive.value = zoneMap['isActive'] ?? false;
      storage.write('isActive', isActive.value);

      getSoilMoisture(zoneId);
      loadDevicesForZone(zoneId);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Zone',
        message: 'Error: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load devices for a specific zone
  Future<void> loadDevicesForZone(String zoneId) async {
    try {
      final response = await supabase
          .from('iot_devices')
          .select()
          .eq('zone_id', zoneId);
    } catch (e) {
      print('Failed to load devices for zone: ${e.toString()}');
    }
  }

  Future<void> getSoilMoisture(String zoneId) async {
    try {
      // Simulate sensor data
      moisture.value = '${60 + DateTime.now().second % 20}%';
      temperature.value = '${25 + DateTime.now().minute % 10}°C';
      humidity.value = '${60 + DateTime.now().hour % 25}%';

      if (selectedZone.isNotEmpty) {
        selectedZone['moisture'] = moisture.value;
      }
    } catch (e) {
      moisture.value = '60%';
      temperature.value = '28°C';
      humidity.value = '65%';
    }
  }

  /// Mengambil data perangkat IoT dari server
  Future<void> loadDevices() async {
    isLoadingDevices.value = true;
    try {
      final response = await supabase
          .from('iot_devices')
          .select('*, zone:zones(*)')
          .order('id', ascending: true);

      final List<IoTDevice> loadedDevices = [];

      for (var device in response) {
        try {
          if (device['zone'] != null) {
            loadedDevices.add(
              IoTDevice(
                id: device['id'] ?? 0,
                name: device['name'] ?? 'Unknown Device',
                type: device['type'] ?? 'unknown',
                status: device['status'] ?? 'offline',
                zone: ZoneModel(
                  id: device['zone']['id'] ?? 0,
                  name: device['zone']['name'] ?? 'Unknown Zone',
                  isActive: device['zone']['isActive'] ?? false,
                  createdAt: DateTime.parse(
                    device['zone']['created_at'] ??
                        DateTime.now().toIso8601String(),
                  ),
                ),
              ),
            );
          }
        } catch (e) {
          DialogHelper.showErrorDialog(message: e.toString());
        }
      }

      devices.value = loadedDevices;
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Memuat Perangkat',
        message: 'Gagal memuat perangkat IoT: ${e.toString()}',
      );
    } finally {
      isLoadingDevices.value = false;
    }
  }

  /// Create a new zone in Supabase with the given name
  Future<void> createZone() async {
    final userId = supabase.auth.currentUser?.id;
    final name = zoneNameController.text.trim();

    if (userId == null || name.isEmpty) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'User belum login atau nama zona kosong.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final existing =
          await supabase
              .from('zones')
              .select('id')
              .eq('name', name)
              .maybeSingle();

      if (existing != null) {
        DialogHelper.showErrorDialog(
          title: 'Nama Zona Sudah Ada',
          message:
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
                'zone_code': selectedZoneCode.value,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      final zoneId = newZone['id']?.toString();
      if (zoneId == null) {
        throw Exception('Failed to get zone ID after creation');
      }

      await supabase.from('zone_users').insert({
        'zone_id': zoneId,
        'user_id': userId
      });

      if (selectedDeviceIds.isNotEmpty) {
        await _assignDevicesToZone(zoneId);
      }

      final Map<String, dynamic> completeZone = Map<String, dynamic>.from(
        newZone,
      );
      completeZone['timer'] = '00:00:00';
      completeZone['moisture'] = '60%';
      zones.add(completeZone);

      zoneTimers.putIfAbsent(zoneId, () => '00:00:00'.obs);

      await DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: '$name berhasil dibuat.',
      );
      zoneNameController.clear();
      selectedDeviceIds.clear();
      Get.offAllNamed('/main');
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal membuat zona',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
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
        message:
            'Zona berhasil dibuat tetapi gagal menambahkan beberapa perangkat: ${e.toString()}',
      );
    }
  }

  /// Perform actual zone deletion in the database
  Future<void> deleteZone(int zoneId) async {
    try {
      isLoading.value = true;

      // Show confirmation dialog before proceeding with deletion
      await DialogHelper.showConfirmationDialog(
        title: 'Hapus Zona',
        message: 'Apakah Anda yakin ingin menghapus ${selectedZone['name']}?',
        onConfirm: () async {
          await supabase
              .from('zones')
              .update({'deleted_at': DateTime.now().toIso8601String()})
              .eq('id', zoneId);

          zones.removeWhere((z) => z['id'] == zoneId);
          stopTimer(zoneId.toString());

          if (selectedZone['id'] == zoneId) {
            selectedZone.clear();
          }

          DialogHelper.showSuccessDialog(
            title: 'Berhasil',
            message: 'Zona berhasil dihapus.',
          );

          Get.offAllNamed('/main');
        },
        onCancel: Get.back,
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal hapus zona',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing zone with new information
  Future<void> updateZone(String zoneId, {required String newName}) async {
    if (newName.trim().isEmpty) {
      DialogHelper.showErrorDialog(
        title: 'Nama Tidak Valid',
        message: 'Nama zona tidak boleh kosong.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final existing =
          await supabase
              .from('zones')
              .select('id')
              .eq('name', newName.trim())
              .neq('id', zoneId)
              .maybeSingle();

      if (existing != null) {
        DialogHelper.showErrorDialog(
          title: 'Nama Zona Sudah Ada',
          message:
              'Zona dengan nama "$newName" sudah terdaftar. Silakan gunakan nama lain.',
        );
        return;
      }

      final updated =
          await supabase
              .from('zones')
              .update({
                'name': newName.trim(),
                'zone_code': selectedZoneCode.value,
              })
              .eq('id', zoneId)
              .select()
              .single();

      final index = zones.indexWhere((z) => z['id'].toString() == zoneId);
      if (index != -1) {
        final currentZone = zones[index];
        zones[index] = Map<String, dynamic>.from({
          ...updated,
          'timer': currentZone['timer'] ?? '00:00:00',
          'moisture': currentZone['moisture'] ?? '60%',
        });
      }

      if (selectedZone['id'].toString() == zoneId) {
        selectedZone['name'] = newName.trim();
      }

      await DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: 'Zona berhasil diperbarui.',
      );
      Get.back();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal update',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle active state for a specific zone
  Future<void> toggleActive(dynamic zoneId, {bool fromtimer = false}) async {
    if (zoneId == null) return;

    final zoneIdStr = zoneId.toString();

    try {
      final zoneIndex = zones.indexWhere(
        (z) => z['id'].toString() == zoneIdStr,
      );
      if (zoneIndex == -1) {
        DialogHelper.showErrorDialog(
          title: 'Error',
          message: 'Zone not found. Please refresh the zones list.',
        );
        return;
      }

      final currentState = zones[zoneIndex]['isActive'] ?? false;
      final newActiveState = !currentState;

      final updatedZone =
          await supabase
              .from('zones')
              .update({'isActive': newActiveState})
              .eq('id', zoneId)
              .select()
              .single();

      // Update the local zones list
      zones[zoneIndex] = Map<String, dynamic>.from({
        ...updatedZone,
        'timer': zones[zoneIndex]['timer'] ?? '00:00:00',
        'moisture': zones[zoneIndex]['moisture'] ?? '60%',
      });

      if (selectedZone['id'].toString() == zoneIdStr) {
        selectedZone['isActive'] = newActiveState;
        isActive.value = newActiveState;
      }

      if (newActiveState) {
        activeCount.value += 1;
        startTimer(zoneIdStr, duration.value);
      } else {
        activeCount.value -= 1;
        stopTimer(zoneIdStr);
      }

      storage.write('zone_active_$zoneIdStr', newActiveState);
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', message: e.toString());
    }
  }

  void listenToZoneChanges() {
    supabase.from('zones').stream(primaryKey: ['id']).listen((updates) {
      for (final update in updates) {
        final updatedZone = update['new'];
        if (updatedZone == null) continue;

        final updatedZoneId = updatedZone['id']?.toString();
        if (updatedZoneId == null) continue;

        final updatedIsActive = updatedZone['isActive'] ?? false;

        final zoneIndex = zones.indexWhere(
          (z) => z['id'].toString() == updatedZoneId,
        );
        if (zoneIndex != -1) {
          final existingZone = zones[zoneIndex];
          zones[zoneIndex] = {
            ...existingZone,
            ...updatedZone,
            'timer': existingZone['timer'] ?? '00:00:00',
            'moisture': existingZone['moisture'] ?? '60%',
          };

          if (updatedIsActive && _zoneTimers[updatedZoneId] == null) {
            startTimer(updatedZoneId, duration.value);
          } else if (!updatedIsActive && _zoneTimers[updatedZoneId] != null) {
            stopTimer(updatedZoneId);
          }

          if (selectedZone['id']?.toString() == updatedZoneId) {
            selectedZone.value = {
              ...selectedZone,
              ...updatedZone,
              'timer': selectedZone['timer'] ?? '00:00:00',
              'moisture': selectedZone['moisture'] ?? '60%',
            };
            isActive.value = updatedIsActive;
          }
        }
      }
    });
  }

  Future<void> startTimer(String zoneId, int durationMinutes) async {
    if (_zoneTimers[zoneId] != null) {
      _zoneTimers[zoneId]?.cancel();
      _zoneTimers[zoneId] = null;
    }

    int totalSeconds = durationMinutes * 60;
    final storedSeconds = storage.read('timer_$zoneId');

    if (storedSeconds != null) {
      try {
        totalSeconds = int.parse(storedSeconds.toString());
      } catch (e) {
        DialogHelper.showErrorDialog(
          title: 'Error Parsing Timer',
          message: 'Error parsing timer value: $e',
        );
      }
    }

    // Initialize the timer display
    zoneTimers.putIfAbsent(zoneId, () => '00:00:00'.obs);

    const oneSecond = Duration(seconds: 1);
    _zoneTimers[zoneId] = Timer.periodic(oneSecond, (timer) {
      if (totalSeconds > 0) {
        totalSeconds--;
        final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
        final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(
          2,
          '0',
        );
        final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

        if (zoneTimers.containsKey(zoneId)) {
          zoneTimers[zoneId]?.value = '$hours:$minutes:$seconds';
        }

        // Save timer to storage
        storage.write('timer_$zoneId', totalSeconds);
      } else {
        stopTimer(zoneId);
        toggleActive(zoneId, fromtimer: true);
      }
    });
  }

  void stopTimer(String zoneId) {
    _zoneTimers[zoneId]?.cancel();
    _zoneTimers[zoneId] = null;

    if (zoneTimers.containsKey(zoneId)) {
      zoneTimers[zoneId]?.value = '00:00:00';
    }

    storage.remove('timer_$zoneId');
  }

  Future<void> _executeScheduledIrrigation(
    String zoneId,
    int duration,
    int scheduleId,
  ) async {
    try {
      final zoneIndex = zones.indexWhere((z) => z['id'].toString() == zoneId);
      if (zoneIndex == -1) return;

      final isZoneActive = zones[zoneIndex]['isActive'] ?? false;
      if (!isZoneActive) {
        this.duration.value = duration;

        storage.remove('timer_$zoneId');
        await toggleActive(zoneId);
        stopTimer(zoneId);

        await startTimer(zoneId, duration);
        final updatedIndex = zones.indexWhere(
          (z) => z['id'].toString() == zoneId,
        );
        if (updatedIndex != -1) {
          zones.refresh();
        }
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Memuat Jadwal',
        message: 'Error ketika memuat jadwal: $e',
      );
    } finally {
      _scheduleTimers.remove(scheduleId);
    }
  }

  Future<void> saveSchedule() async {
    if (selectedDate.value == null || selectedTime.value == null) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Membuat Jadwal',
        message:
            'Tanggal dan waktu tidak boleh kosong. Silahkan pilih tanggal dan waktu terlebih dahulu!',
      );
      return;
    }

    final zoneId = selectedZone['id'].toString();

    try {
      final time = selectedTime.value!;
      final now = DateTime.now();
      final combinedDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        time.hour,
        time.minute,
      );
      if (combinedDateTime.isBefore(now)) {
        DialogHelper.showErrorDialog(
          title: 'Gagal Membuat Jadwal',
          message:
              'Jadwal tidak boleh lebih awal dari waktu saat ini. Silahkan pilih waktu yang lebih baru!',
        );
        return;
      }

      final inserted =
          await supabase
              .from('irrigation_schedules')
              .insert({
                'zone_id': int.parse(zoneId),
                'duration': duration.value,
                'scheduled_at': combinedDateTime.toIso8601String(),
              })
              .select()
              .single();

      schedules.add(inserted);
      loadAllZoneSchedules();
      clearForm();
      DialogHelper.showSuccessDialog(
        title: 'Jadwal Berhasil Disimpan',
        message: 'Jadwal irigasi otomatis Anda berhasil disimpan',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Menyimpan Jadwal',
        message: e.toString(),
      );
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await DialogHelper.showConfirmationDialog(
        title: 'Hapus Jadwal',
        message: 'Apakah anda yakin ingin menghapus jadwal penyiraman ini?',
        onConfirm: () async {
          Get.back();
          await supabase
              .from('irrigation_schedules')
              .delete()
              .eq('id', scheduleId);

          schedules.removeWhere((schedule) => schedule['id'] == scheduleId);
          loadAllZoneSchedules();

          await DialogHelper.showSuccessDialog(
            title: 'Berhasil',
            message: 'Jadwal berhasil dihapus',
          );
        },
        onCancel: () => Get.back(),
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Menghapus Jadwal',
        message: e.toString(),
      );
    }
  }

  Future<void> loadSchedules() async {
    isLoadingSchedules.value = true;
    final zoneId = selectedZone['id']?.toString();
    if (zoneId == null || zoneId.isEmpty) {
      isLoadingSchedules.value = false;
      return;
    }

    try {
      final data = await supabase
          .from('irrigation_schedules')
          .select()
          .eq('zone_id', zoneId)
          .order('scheduled_at', ascending: true);

      schedules.value = List<Map<String, dynamic>>.from(data);

      // final now = DateTime.now();
      // for (var schedule in schedules) {
      //   try {
      //     final scheduledAt = DateTime.parse(schedule['scheduled_at']);
      //     final scheduledId = schedule['id'];
      //     final duration = schedule['duration'] ?? 5;

      //     if (scheduledAt.isAfter(now)) {
      //       final timeUntilSchedule = scheduledAt.difference(now);

      //       _scheduleTimers[schedule['id']] = Timer(timeUntilSchedule, () {
      //         _executeScheduledIrrigation(zoneId, duration, scheduledId);
      //       });
      //     }
      //   } catch (e) {
      //     DialogHelper.showErrorDialog(
      //       title: 'Failed to Parse Schedule',
      //       message: 'Error parsing schedule date: $e',
      //     );
      //   }
      // }
    } catch (e) {
      schedules.value = [];
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  Future<void> loadAllZoneSchedules() async {
    try {
      // Cancel any existing schedule timers
      _scheduleTimers.forEach((id, timer) {
        timer.cancel();
      });
      _scheduleTimers.clear();

      // Load schedules for ALL zones, not just the selected one
      final data = await supabase
          .from('irrigation_schedules')
          .select('*, schedule:zone_schedules(*, zone:zones(*))')
          .order('schedule_at', ascending: true);

      final now = DateTime.now();
      for (var schedule in data) {
        try {
          final scheduledId = schedule['id'];
          final zoneId = schedule['zone_id'].toString();
          final duration = schedule['duration'] ?? 5;
          final scheduledAt = DateTime.parse(schedule['scheduled_at']);

          // Only set timers for future schedules
          if (scheduledAt.isAfter(now)) {
            final timeUntilSchedule = scheduledAt.difference(now);

            _scheduleTimers[scheduledId] = Timer(timeUntilSchedule, () {
              _executeScheduledIrrigation(zoneId, duration, scheduledId);
            });
          }
        } catch (e) {
          DialogHelper.showErrorDialog(
            title: 'Gagal Memuat Jadwal',
            message: 'Error parsing schedule date: $e',
          );
        }
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Schedules',
        message: 'Error: ${e.toString()}',
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
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
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

  Future<void> countActive() async {
    final response = await supabase
        .from('zones')
        .select('id')
        .eq('isActive', true)
        .filter('deleted_at', 'is', null);

    final List<dynamic> data = response as List<dynamic>;
    activeCount.value = data.length;
  }

  void clearForm() {
    selectedZoneCode.value = 1;
    zoneNameController.clear();
    selectedDate.value = DateTime.now();
    selectedTime.value = const TimeOfDay(hour: 6, minute: 0);
    duration.value = 5;
  }

  @override
  void onClose() {
    _zoneTimers.forEach((_, timer) => timer?.cancel());
    clearForm();
    super.onClose();
  }
}
