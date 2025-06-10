import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static SensorService get to => Get.find<SensorService>();

  StreamSubscription<List<Map<String, dynamic>>>? _sensorSubscription;
  final Rx<Map<String, dynamic>?> latestSensorData = Rx<Map<String, dynamic>?>(
    null,
  );

  Future<SensorService> init() async {
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    _startRealtimeSubscription();
  }

  @override
  void onClose() {
    _sensorSubscription?.cancel();
    super.onClose();
  }

  void _startRealtimeSubscription() {
    try {
      _sensorSubscription = _supabase
          .from('sensor_datas')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .listen(
            (data) {
              if (data.isNotEmpty) {
                final newData = {
                  'soil_moisture': data.first['soil_moisture'],
                  'air_moisture': data.first['air_moisture'],
                  'air_humidity': data.first['air_humidity'],
                  'rainfall_intensity': data.first['rainfall_intensity'],
                };
                latestSensorData.value = newData;
              }
            },
            onError: (error) {
              _fallbackRefresh();
            },
          );
    } catch (e) {
      _fallbackRefresh();
    }
  }

  void _fallbackRefresh() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!Get.isRegistered<SensorService>()) {
        timer.cancel();
        return;
      }
      getSensorDataManual();
    });
  }

  Future<Map<String, dynamic>?> getSensorData() async {
    try {
      final response =
          await _supabase
              .from('sensor_datas')
              .select(
                'soil_moisture, air_moisture, air_humidity, rainfall_intensity',
              )
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
      if (response != null) {
        latestSensorData.value = response;
        updateLatestData(response);
        latestSensorData.refresh();
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> getSensorDataManual() async {
    await getSensorData();
  }

  Map<String, dynamic>? getCachedSensorData() {
    return latestSensorData.value;
  }

  Future<Map<String, dynamic>?> forceRefresh() async {
    return await getSensorData();
  }

  void updateLatestData(Map<String, dynamic> data) {
    latestSensorData.value = data;
    latestSensorData.refresh();
  }

  Future<void> initialLoad() async {
    await getSensorData();
  }

  Future<void> refreshData() async {
    await getSensorData();
  }
}
