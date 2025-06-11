import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static SensorService get to => Get.find<SensorService>();

  StreamSubscription<List<Map<String, dynamic>>>? _sensorSubscription;
  final Rx<Map<String, dynamic>?> latestSensorData = Rx<Map<String, dynamic>?>(
    null,
  );

  Timer? _reconnectTimer;
  Timer? _fallbackTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  bool _isReconnecting = false;

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
    _cleanup();
    super.onClose();
  }

  void _cleanup() {
    _sensorSubscription?.cancel();
    _reconnectTimer?.cancel();
    _fallbackTimer?.cancel();
    _sensorSubscription = null;
    _reconnectTimer = null;
    _fallbackTimer = null;
  }

  void _startRealtimeSubscription() {
    if (_isReconnecting) return;

    try {
      _sensorSubscription?.cancel();
      _sensorSubscription = _supabase
          .from('sensor_datas')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .listen(
            (data) {
              _onRealtimeSuccess(data);
            },
            onError: (error) {
              _handleRealtimeError(error);
            },
            onDone: () {
              _handleRealtimeDisconnect();
            },
          );

      _reconnectAttempts = 0;
      _fallbackTimer?.cancel();
    } catch (e) {
      _handleRealtimeError(e);
    }
  }

  void _onRealtimeSuccess(List<Map<String, dynamic>> data) {
    if (data.isNotEmpty) {
      final newData = {
        'soil_moisture': data.first['soil_moisture'],
        'air_temperature': data.first['air_temperature'],
        'air_humidity': data.first['air_humidity'],
        'rainfall_intensity': data.first['rainfall_intensity'],
      };
      latestSensorData.value = newData;
    }
  }

  void _handleRealtimeError(dynamic error) {
    if (_isReconnecting) return;

    _sensorSubscription?.cancel();
    _sensorSubscription = null;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else {
      _startFallbackPolling();
    }
  }

  void _handleRealtimeDisconnect() {
    if (!_isReconnecting && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isReconnecting) return;

    _isReconnecting = true;
    _reconnectAttempts++;

    final delay = Duration(
      seconds: (_initialReconnectDelay.inSeconds * _reconnectAttempts).clamp(
        2,
        30,
      ),
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _isReconnecting = false;
      if (Get.isRegistered<SensorService>()) {
        _startRealtimeSubscription();
      }
    });
  }

  void _startFallbackPolling() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!Get.isRegistered<SensorService>()) {
        timer.cancel();
        return;
      }
      getSensorDataManual();

      if (_reconnectAttempts < _maxReconnectAttempts) {
        timer.cancel();
        _reconnectAttempts = 0;
        _startRealtimeSubscription();
      }
    });
  }

  Future<Map<String, dynamic>?> getSensorData() async {
    try {
      final response =
          await _supabase
              .from('sensor_datas')
              .select(
                'soil_moisture, air_temperature, air_humidity, rainfall_intensity',
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

  void retryRealtimeConnection() {
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _fallbackTimer?.cancel();
    _startRealtimeSubscription();
  }
}
