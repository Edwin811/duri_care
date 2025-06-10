import 'package:duri_care/core/services/zone_service.dart';
import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/iot_device_model.dart';
import 'package:duri_care/models/zone_model.dart';
import 'package:duri_care/models/zone_schedule.dart';
import 'package:duri_care/models/irrigation_schedule.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';

class ZoneController extends GetxController {
  final ZoneService _zoneService = Get.find<ZoneService>();
  final UserService _userService = Get.find<UserService>();
  final storage = GetStorage();

  final zones = <Map<String, dynamic>>[].obs;
  final selectedZone = <String, dynamic>{}.obs;
  final RxBool isActive = false.obs;
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
  final RxInt durationIrg = 5.obs;
  final schedules = <ZoneScheduleModel>[].obs;
  final TextEditingController zoneNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoadingDevices = false.obs;
  final devices = <IotDeviceModel>[].obs;
  final selectedDeviceIds = <int>[].obs;
  final userID = Supabase.instance.client.auth.currentUser?.id;
  final isLoading = false.obs;
  final RxInt manualDuration = 5.obs;

  Map<String, dynamic> _zoneModelToMap(ZoneModel model) => {
    'id': model.id,
    'zone_code': model.zoneCode,
    'name': model.name,
    'is_active': model.isActive,
    'duration': model.duration,
    'created_at': model.createdAt?.toIso8601String(),
    'deleted_at': model.deletedAt?.toIso8601String(),
  };
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() async {
    try {
      await loadZones();
      _setupZoneTimers();
      if (zones.isNotEmpty) {
        final firstZone = zones.first;
        isActive.value = firstZone['is_active'] ?? false;
        manualDuration.value = firstZone['duration'] ?? 5;
      }
      listenToZoneChanges();
      _loadBackgroundData();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Initialization Error',
        message: 'Failed to initialize zone controller: ${e.toString()}',
      );
    }
  }

  void _loadBackgroundData() {
    Future.wait([
      _loadAllZoneSchedulesBackground(),
      _loadSchedulesBackground(),
      _loadDevicesBackground(),
    ]).catchError((error) {
      return <void>[];
    });
  }

  Future<void> _loadAllZoneSchedulesBackground() async {
    await loadAllZoneSchedules();
  }

  Future<void> _loadSchedulesBackground() async {
    if (selectedZone.isNotEmpty) {
      await loadSchedules();
    }
  }

  Future<void> _loadDevicesBackground() async {
    await loadDevices();
  }

  @override
  void onClose() {
    _zoneTimers.forEach((_, timer) => timer?.cancel());
    clearForm();
    zoneNameController.dispose();
    super.onClose();
  }

  void _setupZoneTimers() {
    for (var zone in zones) {
      final zoneId = zone['id']?.toString();
      if (zoneId != null) {
        final isZoneActive = zone['is_active'] == true;
        final remainingTime = storage.read('timer_$zoneId');
        if (!isZoneActive && remainingTime != null) {
          storage.remove('timer_$zoneId');
        }

        if (isZoneActive) {
          startTimer(zoneId, _getZoneDuration(zoneId));
        } else {
          zoneTimers[zoneId]?.value = '00:00:00';
        }
      }
    }
  }

  Future<void> loadZones() async {
    try {
      if (userID == null) {
        DialogHelper.showErrorDialog(
          title: 'Authentication Error',
          message: 'User not logged in',
        );
        return;
      }

      final zoneModels = await _zoneService.loadZones(userID!);
      zones.value = zoneModels.map((model) => _zoneModelToMap(model)).toList();
      _cleanupStaleTimerData();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Zones',
        message: 'Error: ${e.toString()}',
      );
    }
  }

  void _cleanupStaleTimerData() {
    final storage = GetStorage();
    final activeZoneIds =
        zones
            .where((zone) => zone['is_active'] == true)
            .map((zone) => zone['id']?.toString())
            .where((id) => id != null)
            .toSet();

    final keys = storage.getKeys();
    for (final key in keys) {
      if (key.toString().startsWith('timer_')) {
        final zoneId = key.toString().replaceFirst('timer_', '');

        if (!activeZoneIds.contains(zoneId)) {
          storage.remove(key);
        }
      }
    }
  }

  Future<void> loadZoneById(dynamic zoneId) async {
    if (zoneId == null) return;
    final zoneIdInt = int.tryParse(zoneId.toString());
    if (zoneIdInt == null) return;
    isLoading.value = true;
    try {
      if (userID == null) {
        DialogHelper.showErrorDialog(
          title: 'Authentication Error',
          message: 'User not logged in',
        );
        return;
      }
      ZoneModel zoneModel = await _zoneService.loadZoneById(zoneIdInt, userID!);
      Map<String, dynamic> zoneMap = _zoneModelToMap(zoneModel);
      zoneMap['timer'] = zoneTimers[zoneIdInt.toString()]?.value ?? '00:00:00';
      selectedZone.value = zoneMap;
      manualDuration.value = zoneModel.duration;
      loadSchedules();
      isActive.value = zoneModel.isActive;
      getSoilMoisture(zoneIdInt.toString());
      loadDevicesForZone(zoneIdInt);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Zone',
        message: 'Error: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDevicesForZone(int zoneId) async {
    try {
      devices.value = await _zoneService.loadDevicesForZone(zoneId);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error Loading Devices',
        message: 'Failed to load devices: ${e.toString()}',
      );
    }
  }

  Future<void> getSoilMoisture(String zoneId) async {
    try {
      moisture.value = '${60 + DateTime.now().second % 20}%';
      temperature.value = '${25 + DateTime.now().minute % 10}°C';
      humidity.value = '${60 + DateTime.now().hour % 25}%';
      if (selectedZone.isNotEmpty) selectedZone['moisture'] = moisture.value;
    } catch (e) {
      moisture.value = '60%';
      temperature.value = '28°C';
      humidity.value = '65%';
    }
  }

  Future<void> loadDevices() async {
    isLoadingDevices.value = true;
    try {
      devices.value = await _zoneService.loadAllDevices();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Memuat Perangkat',
        message: 'Error: ${e.toString()}',
      );
    } finally {
      isLoadingDevices.value = false;
    }
  }

  Future<void> createZone() async {
    final name = zoneNameController.text.trim();
    if (userID == null || name.isEmpty) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'User belum login atau nama zona kosong',
      );
      return;
    }
    final validationError = validateName(name);
    if (validationError != null) {
      DialogHelper.showErrorDialog(
        title: 'Nama Zona Tidak Valid',
        message: validationError,
      );
      return;
    }
    if (formKey.currentState?.validate() != true) {
      DialogHelper.showErrorDialog(
        title: 'Validasi Gagal',
        message: 'Pastikan semua field telah diisi dengan benar',
      );
      return;
    }

    final existingZoneWithCode = zones.firstWhereOrNull(
      (zone) => zone['zone_code'] == selectedZoneCode.value,
    );
    if (existingZoneWithCode != null) {
      DialogHelper.showErrorDialog(
        title: 'Kode Zona Sudah Digunakan',
        message:
            'Kode zona ${selectedZoneCode.value} sudah digunakan oleh "${existingZoneWithCode['name']}". Silakan pilih kode zona lain.',
      );
      return;
    }

    try {
      isLoading.value = true;
      FocusManager.instance.primaryFocus?.unfocus();

      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final optimisticZone = {
        'id': tempId,
        'zone_code': selectedZoneCode.value,
        'name': name,
        'is_active': false,
        'duration': 5,
        'created_at': DateTime.now().toIso8601String(),
        'deleted_at': null,
        'timer': '00:00:00',
      };

      zones.add(optimisticZone);
      zoneTimers.putIfAbsent(tempId, () => '00:00:00'.obs);

      Get.offAllNamed('/main');
      DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: '$name berhasil dibuat',
      );

      try {
        final zoneModel = await _zoneService.createZone(
          name: name,
          zoneCode: selectedZoneCode.value,
          userId: userID!,
        );

        final index = zones.indexWhere((z) => z['id'] == tempId);
        if (index != -1) {
          final realZoneMap = _zoneModelToMap(zoneModel);
          realZoneMap['timer'] = '00:00:00';
          zones[index] = realZoneMap;

          zoneTimers.remove(tempId);
          zoneTimers.putIfAbsent(zoneModel.id.toString(), () => '00:00:00'.obs);
        }
      } catch (dbError) {
        zones.removeWhere((z) => z['id'] == tempId);
        zoneTimers.remove(tempId);

        Future.delayed(const Duration(milliseconds: 1500), () {
          DialogHelper.showErrorDialog(
            title: 'Gagal Membuat Zona',
            message: 'Error: ${dbError.toString()}',
          );
        });
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal membuat zona',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteZone(int zoneId) async {
    final isOwner = await _userService.isOwner();
    if (!isOwner) {
      DialogHelper.showErrorDialog(
        title: 'Akses Ditolak',
        message: 'Hanya pemilik yang dapat menghapus zona',
      );
      return;
    }

    try {
      await DialogHelper.showConfirmationDialog(
        title: 'Hapus Zona',
        message: 'Apakah Anda yakin ingin menghapus ${selectedZone['name']}?',
        onConfirm: () async {
          Get.back();
          isLoading.value = true;

          final zoneIndex = zones.indexWhere((z) => z['id'] == zoneId);
          Map<String, dynamic>? originalZone;

          if (zoneIndex != -1) {
            originalZone = Map<String, dynamic>.from(zones[zoneIndex]);
            zones.removeAt(zoneIndex);
          }

          stopTimer(zoneId.toString());
          if (selectedZone['id'] == zoneId) selectedZone.clear();

          Get.offAllNamed('/main');
          DialogHelper.showSuccessDialog(
            title: 'Berhasil',
            message: 'Zona berhasil dihapus',
          );

          try {
            await _zoneService.deleteZone(zoneId);
            print('Zone deleted successfully from database');
          } catch (dbError) {
            print('Database deletion failed: $dbError');

            if (originalZone != null) {
              zones.insert(zoneIndex, originalZone);
              zoneTimers.putIfAbsent(zoneId.toString(), () => '00:00:00'.obs);
            }

            Future.delayed(const Duration(milliseconds: 1500), () {
              DialogHelper.showErrorDialog(
                title: 'Sinkronisasi Gagal',
                message: 'Penghapusan dibatalkan: ${dbError.toString()}',
              );
            });
          } finally {
            isLoading.value = false;
          }
        },
        onCancel: () => Get.back(),
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal menampilkan konfirmasi: ${e.toString()}',
      );
    }
  }

  Future<void> updateZone(String zoneId, {required String newName}) async {
    final isOwner = await _userService.isOwner();
    if (!isOwner) {
      DialogHelper.showErrorDialog(
        title: 'Akses Ditolak',
        message: 'Hanya pemilik yang dapat mengubah zona',
      );
      return;
    }

    if (newName.trim().isEmpty) {
      DialogHelper.showErrorDialog(
        title: 'Nama Tidak Valid',
        message: 'Nama zona tidak boleh kosong',
      );
      return;
    }

    final validationError = validateName(newName, excludeZoneId: zoneId);
    if (validationError != null) {
      DialogHelper.showErrorDialog(
        title: 'Nama Zona Tidak Valid',
        message: validationError,
      );
      return;
    }

    if (formKey.currentState?.validate() != true) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Pastikan semua field telah diisi dengan benar',
      );
      return;
    }

    try {
      isLoading.value = true;
      FocusManager.instance.primaryFocus?.unfocus();

      final index = zones.indexWhere((z) => z['id'].toString() == zoneId);
      Map<String, dynamic>? originalZone;
      if (index != -1) {
        originalZone = Map<String, dynamic>.from(zones[index]);
        zones[index] = {
          ...zones[index],
          'name': newName.trim(),
          'zone_code': selectedZoneCode.value,
        };
      }

      if (selectedZone['id'].toString() == zoneId) {
        selectedZone['name'] = newName.trim();
        selectedZone['zone_code'] = selectedZoneCode.value;
      }
      try {
        await _zoneService.updateZone(
          zoneId: zoneId,
          newName: newName.trim(),
          zoneCode: selectedZoneCode.value,
        );
      } catch (dbError) {
        if (originalZone != null && index != -1) {
          zones[index] = originalZone;
        }
        Future.delayed(const Duration(milliseconds: 1500), () {
          DialogHelper.showErrorDialog(
            title: 'Gagal Memperbarui Zona',
            message: 'Kode zona sudah digunakan oleh zona lain.',
          );
        });
      }
      Get.back();
      zones.refresh();
      DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: 'Zona berhasil diperbarui',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal update',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActive(dynamic zoneId, {bool fromTimer = false}) async {
    if (zoneId == null) return;
    final zoneIdStr = zoneId.toString();
    try {
      final zoneIndex = zones.indexWhere(
        (z) => z['id'].toString() == zoneIdStr,
      );
      if (zoneIndex == -1) return;

      final currentState = zones[zoneIndex]['is_active'] ?? false;
      final newState = !currentState;

      zones[zoneIndex]['is_active'] = newState;
      zones.refresh();

      if (selectedZone.isNotEmpty &&
          selectedZone['id'].toString() == zoneIdStr) {
        selectedZone['is_active'] = newState;
        selectedZone.refresh();
        isActive.value = newState;
      }

      if (newState) {
        activeCount.value += 1;
        startTimer(zoneIdStr, _getZoneDuration(zoneIdStr));
      } else {
        activeCount.value = activeCount.value > 0 ? activeCount.value - 1 : 0;
        stopTimer(zoneIdStr);
      }

      _updateZoneInBackground(zoneId, zoneIndex, newState);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error Toggling Zone',
        message: e.toString(),
      );
    }
  }

  Future<void> _updateZoneInBackground(
    dynamic zoneId,
    int zoneIndex,
    bool newState,
  ) async {
    try {
      final updatedZone = await _zoneService.toggleZoneActive(
        zoneId,
        type: 'manual',
      );
      storage.write('zone_${zoneId.toString()}_is_active', newState);
      if (updatedZone.isActive != newState) {
        zones[zoneIndex]['is_active'] = updatedZone.isActive;
        zones.refresh();
        if (selectedZone.isNotEmpty &&
            selectedZone['id'].toString() == zoneId.toString()) {
          selectedZone['is_active'] = updatedZone.isActive;
          selectedZone.refresh();
          isActive.value = updatedZone.isActive;
        }
      }
    } catch (e) {
      print('Background zone update error: $e');
    }
  }

  Future<void> saveManualDuration() async {
    final zoneId = selectedZone['id'];
    if (zoneId == null) return;
    try {
      await _zoneService.saveDuration(zoneId, manualDuration.value);
      await loadZones();
      await loadZoneById(zoneId);
      DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: 'Durasi berhasil disimpan',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Menyimpan Durasi',
        message: e.toString(),
      );
    }
  }

  void listenToZoneChanges() {
    _zoneService.zoneChangesStream().listen((updates) {
      for (final update in updates) {
        final updatedZoneData = update['new'];
        if (updatedZoneData == null) continue;
        final updatedZoneId = updatedZoneData['id']?.toString();
        if (updatedZoneId == null) continue;
        final ZoneModel updatedZoneModel = ZoneModel.fromMap(updatedZoneData);
        final Map<String, dynamic> mappedUpdatedZone = _zoneModelToMap(
          updatedZoneModel,
        );
        final updatedIsActive = mappedUpdatedZone['is_active'] ?? false;
        final zoneIndex = zones.indexWhere(
          (z) => z['id'].toString() == updatedZoneId,
        );
        if (zoneIndex != -1) {
          final existingZone = zones[zoneIndex];
          zones[zoneIndex] = {
            ...existingZone,
            ...mappedUpdatedZone,
            'timer': existingZone['timer'] ?? '00:00:00',
          };
          if (updatedIsActive && _zoneTimers[updatedZoneId] == null) {
            startTimer(updatedZoneId, _getZoneDuration(updatedZoneId));
          } else if (!updatedIsActive && _zoneTimers[updatedZoneId] != null) {
            stopTimer(updatedZoneId);
          }
          if (selectedZone['id']?.toString() == updatedZoneId) {
            selectedZone.value = {
              ...selectedZone,
              ...mappedUpdatedZone,
              'timer': selectedZone['timer'] ?? '00:00:00',
              'moisture': selectedZone['moisture'] ?? '60%',
            };
            isActive.value = updatedIsActive;
          }
        }
      }
      zones.refresh();
    });
  }

  int _getZoneDuration(String zoneId) {
    if (selectedZone.isNotEmpty && selectedZone['id']?.toString() == zoneId) {
      return selectedZone['duration'] ?? manualDuration.value;
    }
    final zoneIndex = zones.indexWhere((z) => z['id']?.toString() == zoneId);
    if (zoneIndex != -1) {
      return zones[zoneIndex]['duration'] ?? manualDuration.value;
    }
    return manualDuration.value;
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
        storage.write('timer_$zoneId', totalSeconds);
      } else {
        stopTimer(zoneId);
        _deactivateZoneOnTimerExpiry(zoneId);
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

  Future<void> _deactivateZoneOnTimerExpiry(String zoneId) async {
    try {
      final zoneIndex = zones.indexWhere((z) => z['id'].toString() == zoneId);
      if (zoneIndex == -1) return;

      final currentState = zones[zoneIndex]['is_active'] ?? false;
      if (currentState) {
        print('Timer expired for zone $zoneId - deactivating');

        zones[zoneIndex]['is_active'] = false;
        zones.refresh();

        if (selectedZone.isNotEmpty &&
            selectedZone['id'].toString() == zoneId) {
          selectedZone['is_active'] = false;
          selectedZone.refresh();
          isActive.value = false;
        }

        activeCount.value = activeCount.value > 0 ? activeCount.value - 1 : 0;

        _updateZoneInBackground(zoneId, zoneIndex, false);
      }
    } catch (e) {
      // Log error silently - don't show dialog for timer expiry issues
      print('Error deactivating zone on timer expiry: $e');
    }
  }

  Future<void> _executeScheduledIrrigation(
    String zoneId,
    int duration,
    int scheduleId,
  ) async {
    try {
      final zoneIndex = zones.indexWhere((z) => z['id'].toString() == zoneId);
      if (zoneIndex == -1) return;
      final isZoneActive = zones[zoneIndex]['is_active'] ?? false;
      if (!isZoneActive) {
        storage.remove('timer_$zoneId');

        zones[zoneIndex]['is_active'] = true;
        zones.refresh();
        if (selectedZone['id']?.toString() == zoneId) {
          selectedZone['is_active'] = true;
          selectedZone.refresh();
          isActive.value = true;
        }
        await startTimer(zoneId, duration);

        _updateScheduledZoneInBackground(zoneId, duration, scheduleId);
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

  Future<void> _updateScheduledZoneInBackground(
    String zoneId,
    int duration,
    int scheduleId,
  ) async {
    await _zoneService.toggleZoneActive(zoneId, type: 'auto');
    // await _zoneService.markScheduleAsExecuted(scheduleId);
    if (selectedZone['id']?.toString() == zoneId) {
      await loadSchedules(preserveFormDuration: true);
    }
    await loadAllZoneSchedules();
  }

  Future<void> saveSchedule() async {
    final zoneId = selectedZone['id']?.toString();
    if (zoneId == null) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Zona tidak terpilih',
      );
      return;
    }

    if (selectedDate.value == null || selectedTime.value == null) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Membuat Jadwal',
        message: 'Tanggal dan waktu tidak boleh kosong',
      );
      return;
    }

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
        message: 'Jadwal tidak boleh lebih awal dari waktu saat ini',
      );
      return;
    }

    final duplicateSchedule =
        schedules.where((schedule) {
          final scheduledAt = schedule.schedule.scheduledAt;
          return scheduledAt.year == combinedDateTime.year &&
              scheduledAt.month == combinedDateTime.month &&
              scheduledAt.day == combinedDateTime.day &&
              scheduledAt.hour == combinedDateTime.hour &&
              scheduledAt.minute == combinedDateTime.minute;
        }).firstOrNull;

    if (duplicateSchedule != null) {
      DialogHelper.showErrorDialog(
        title: 'Jadwal Sudah Ada',
        message: 'Sudah ada jadwal pada tanggal dan waktu yang sama',
      );
      return;
    }
    clearFormSchedule();

    final optimisticScheduleData = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'duration': durationIrg.value,
      'scheduled_at': combinedDateTime.toIso8601String(),
      'executed': false,
      'status_id': 1,
    };

    _addOptimisticSchedule(optimisticScheduleData, combinedDateTime, zoneId);

    DialogHelper.showSuccessDialog(
      title: 'Jadwal Berhasil Disimpan',
      message: 'Jadwal irigasi otomatis Anda berhasil disimpan',
    );

    _saveScheduleInBackground(combinedDateTime, zoneId);
  }

  void _saveScheduleInBackground(
    DateTime combinedDateTime,
    String zoneId,
  ) async {
    try {
      final hasPermission = await _userService.hasZonePermission(
        zoneId,
        'allow_auto_schedule',
      );

      if (!hasPermission) {
        _removeOptimisticSchedule(combinedDateTime);
        DialogHelper.showErrorDialog(
          title: 'Akses Ditolak',
          message:
              'Anda tidak memiliki izin untuk membuat jadwal otomatis pada zona ini',
        );
        return;
      }

      final scheduleData = await _zoneService.createSchedule(
        scheduledDateTime: combinedDateTime,
        duration: durationIrg.value,
        zoneId: zoneId,
      );

      _updateOptimisticScheduleWithRealData(scheduleData, combinedDateTime);

      _backgroundReloadSchedules();
    } catch (e) {
      _removeOptimisticSchedule(combinedDateTime);
      DialogHelper.showErrorDialog(
        title: 'Gagal Menyimpan Jadwal',
        message: e.toString(),
      );
    }
  }

  void _backgroundReloadSchedules() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      final currentLoadingState = isLoadingSchedules.value;
      await loadSchedules(preserveFormDuration: true);
      if (!currentLoadingState) {
        isLoadingSchedules.value = false;
      }
    });
  }

  Future<void> deleteSchedule(int scheduleId, int zoneId) async {
    final zoneIdStr = zoneId.toString();
    final hasPermission = await _userService.hasZonePermission(
      zoneIdStr,
      'allow_auto_schedule',
    );
    if (!hasPermission) {
      DialogHelper.showErrorDialog(
        title: 'Akses Ditolak',
        message:
            'Anda tidak memiliki izin untuk menghapus jadwal irigasi otomatis pada zona ini',
      );
      return;
    }
    try {
      isLoadingSchedules.value = true;
      bool confirmed = false;
      await DialogHelper.showConfirmationDialog(
        title: 'Hapus Jadwal',
        message: 'Apakah Anda yakin ingin menghapus jadwal ini?',
        onConfirm: () {
          confirmed = true;
          Get.back();
        },
        onCancel: () {
          Get.back();
          isLoadingSchedules.value = false;
        },
      );
      if (confirmed) {
        try {
          final result = await _zoneService.deleteSchedule(scheduleId, zoneId);
          if (result['success']) {
            await loadSchedules();
            String message = result['message'];
            if (result['wasCompletelyDeleted']) {
              message = 'Jadwal berhasil dihapus sepenuhnya';
            } else {
              final remainingZones = result['remainingZones'] ?? 0;
              message =
                  'Jadwal berhasil dihapus dari zona ini. Jadwal masih digunakan oleh $remainingZones zona lainnya';
            }
            DialogHelper.showSuccessDialog(title: 'Berhasil', message: message);
          }
        } catch (e) {
          DialogHelper.showErrorDialog(
            title: 'Gagal Menghapus Jadwal',
            message: e.toString(),
          );
        }
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Menghapus Jadwal',
        message: e.toString(),
      );
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  Future<void> loadSchedules({bool preserveFormDuration = false}) async {
    final zoneId = selectedZone['id'];
    if (zoneId == null) {
      isLoadingSchedules.value = false;
      return;
    }

    final wasLoading = isLoadingSchedules.value;
    if (!wasLoading) {
      isLoadingSchedules.value = true;
    }

    try {
      final futures = <Future>[];

      final schedulesFuture = _zoneService.loadZoneSchedules(zoneId);
      futures.add(schedulesFuture);
      if (!preserveFormDuration) {
        final storedDuration = storage.read('zone_${zoneId}_duration');
        if (storedDuration != null) {
          durationIrg.value = storedDuration;
        }
      } else {
        final storedDuration = storage.read('zone_${zoneId}_duration');
        if (storedDuration != null) {
          storage.remove('zone_${zoneId}_duration');
        }
      }

      final results = await Future.wait(futures);
      final loadedSchedules = results[0] as List<ZoneScheduleModel>;

      schedules.value = loadedSchedules;

      _setupScheduleTimersInBackground(loadedSchedules);
    } catch (e) {
      schedules.value = [];
      if (!wasLoading) {
        DialogHelper.showErrorDialog(
          title: 'Failed to Load Schedules',
          message: 'Error: ${e.toString()}',
        );
      }
    } finally {
      if (!wasLoading) {
        isLoadingSchedules.value = false;
      }
    }
  }

  void _setupScheduleTimersInBackground(
    List<ZoneScheduleModel> loadedSchedules,
  ) {
    Future.microtask(() async {
      try {
        final now = DateTime.now();
        for (var item in loadedSchedules) {
          try {
            final scheduledAt = item.schedule.scheduledAt;
            final duration = item.schedule.duration;
            final scheduledId = item.schedule.id;
            storage.write('schedule_${scheduledId}_duration', duration);
            if (scheduledAt.isAfter(now)) {
              final timeUntilSchedule = scheduledAt.difference(now);
              _scheduleTimers[scheduledId] = Timer(
                timeUntilSchedule,
                () => _executeScheduledIrrigation(
                  item.zoneId.toString(),
                  duration,
                  scheduledId,
                ),
              );
            }
          } catch (e) {
            DialogHelper.showErrorDialog(
              title: 'Failed to Process Schedule',
              message: 'Error: $e',
            );
          }
        }
      } catch (e) {
        DialogHelper.showErrorDialog(
          title: 'Failed to Setup Schedule Timers',
          message: 'Error: ${e.toString()}',
        );
      }
    });
  }

  Future<void> loadAllZoneSchedules() async {
    try {
      _scheduleTimers.forEach((id, timer) => timer.cancel());
      _scheduleTimers.clear();
      final scheduleList = await _zoneService.loadAllZoneSchedules();
      final now = DateTime.now();
      storage.remove('schedules');
      for (var item in scheduleList) {
        try {
          final scheduledId = item.schedule.id;
          final scheduledAt = item.schedule.scheduledAt;
          final duration = item.schedule.duration;
          final zoneId = item.zoneId.toString();
          if (scheduledAt.isAfter(now)) {
            final timeUntilSchedule = scheduledAt.difference(now);
            _scheduleTimers[scheduledId] = Timer(
              timeUntilSchedule,
              () => _executeScheduledIrrigation(zoneId, duration, scheduledId),
            );
          }
        } catch (e) {
          DialogHelper.showErrorDialog(
            title: 'Failed to Process Schedule',
            message: 'Error: $e',
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
    if (pickedTime != null) selectedTime.value = pickedTime;
  }

  String? validateName(String? value, {String? excludeZoneId}) {
    if (value == null || value.isEmpty) return 'Nama zona tidak boleh kosong';
    if (value.length < 3) return 'Nama zona minimal 3 karakter';
    final similarZone = _findSimilarZoneName(value.trim(), excludeZoneId);
    if (similarZone != null) {
      return 'Nama zona "${similarZone['name']}" sudah ada (tidak boleh mirip)';
    }
    return null;
  }

  Map<String, dynamic>? _findSimilarZoneName(
    String newName, [
    String? excludeZoneId,
  ]) {
    final normalizedNewName = newName.toLowerCase().trim();
    for (var zone in zones) {
      final zoneId = zone['id']?.toString();
      final zoneName = zone['name']?.toString() ?? '';
      if (excludeZoneId != null && zoneId == excludeZoneId) continue;
      final normalizedZoneName = zoneName.toLowerCase().trim();
      if (normalizedZoneName == normalizedNewName) return zone;
      final cleanNewName = normalizedNewName.replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      final cleanZoneName = normalizedZoneName.replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      if (cleanNewName.isNotEmpty && cleanZoneName == cleanNewName) return zone;
    }
    return null;
  }

  void clearForm() {
    zoneNameController.clear();
    selectedZoneCode.value = 1;
    selectedZone.clear();
  }

  void clearFormSchedule() {
    selectedDate.value = DateTime.now();
    selectedTime.value = const TimeOfDay(hour: 6, minute: 0);
    durationIrg.value = 5;
  }

  Future<bool> isOwner() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return false;
      final userResponse =
          await Supabase.instance.client
              .from('users')
              .select('user_roles!inner(roles!inner(role_name))')
              .eq('id', userId)
              .single();
      final rolesList = userResponse['user_roles'] as List;
      if (rolesList.isEmpty) return false;
      return rolesList[0]['roles']['role_name'] == 'owner';
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasAutoSchedulePermission() async {
    final zoneId = selectedZone['id']?.toString();
    if (zoneId == null) return false;
    return await _userService.hasAutoSchedulePermission(zoneId);
  }

  void _addOptimisticSchedule(
    Map<String, dynamic> scheduleData,
    DateTime combinedDateTime,
    String zoneId,
  ) {
    try {
      final optimisticSchedule = ZoneScheduleModel(
        zoneId: int.parse(zoneId),
        schedule: IrrigationScheduleModel(
          id: scheduleData['id'] ?? DateTime.now().millisecondsSinceEpoch,
          scheduledAt: combinedDateTime,
          duration: durationIrg.value,
          executed: false,
          statusId: 1,
        ),
      );

      final currentSchedules = List<ZoneScheduleModel>.from(schedules);
      currentSchedules.add(optimisticSchedule);
      currentSchedules.sort(
        (a, b) => a.schedule.scheduledAt.compareTo(b.schedule.scheduledAt),
      );

      schedules.value = currentSchedules;

      final now = DateTime.now();
      if (combinedDateTime.isAfter(now)) {
        final timeUntilSchedule = combinedDateTime.difference(now);
        final scheduledId = optimisticSchedule.schedule.id;
        _scheduleTimers[scheduledId] = Timer(
          timeUntilSchedule,
          () => _executeScheduledIrrigation(
            zoneId,
            durationIrg.value,
            scheduledId,
          ),
        );
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Menambahkan Jadwal',
        message: 'Terjadi kesalahan saat menambahkan jadwal: $e',
      );
    }
  }

  void _removeOptimisticSchedule(DateTime combinedDateTime) {
    try {
      final updatedSchedules =
          schedules.where((schedule) {
            final scheduledAt = schedule.schedule.scheduledAt;
            return !(scheduledAt.year == combinedDateTime.year &&
                scheduledAt.month == combinedDateTime.month &&
                scheduledAt.day == combinedDateTime.day &&
                scheduledAt.hour == combinedDateTime.hour &&
                scheduledAt.minute == combinedDateTime.minute);
          }).toList();

      schedules.value = updatedSchedules;
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Menghapus Jadwal',
        message: 'Terjadi kesalahan saat menghapus jadwal: $e',
      );
    }
  }

  void _updateOptimisticScheduleWithRealData(
    Map<String, dynamic> scheduleData,
    DateTime combinedDateTime,
  ) {
    try {
      final scheduleIndex = schedules.indexWhere((schedule) {
        final scheduledAt = schedule.schedule.scheduledAt;
        return scheduledAt.year == combinedDateTime.year &&
            scheduledAt.month == combinedDateTime.month &&
            scheduledAt.day == combinedDateTime.day &&
            scheduledAt.hour == combinedDateTime.hour &&
            scheduledAt.minute == combinedDateTime.minute;
      });

      if (scheduleIndex != -1) {
        final currentSchedule = schedules[scheduleIndex];
        final updatedSchedule = ZoneScheduleModel(
          zoneId: currentSchedule.zoneId,
          schedule: IrrigationScheduleModel(
            id: scheduleData['id'],
            scheduledAt: combinedDateTime,
            duration: scheduleData['duration'],
            executed: scheduleData['executed'] ?? false,
            statusId: scheduleData['status_id'] ?? 1,
          ),
        );

        final updatedSchedules = List<ZoneScheduleModel>.from(schedules);
        updatedSchedules[scheduleIndex] = updatedSchedule;
        schedules.value = updatedSchedules;
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Memperbarui Jadwal',
        message: 'Terjadi kesalahan saat memperbarui jadwal: $e',
      );
    }
  }

  void resetDurationToDefault() {
    durationIrg.value = 5;
    final zoneId = selectedZone['id']?.toString();
    if (zoneId != null) {
      storage.remove('zone_${zoneId}_duration');
    }
  }
}
