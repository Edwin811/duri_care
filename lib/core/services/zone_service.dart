import 'package:duri_care/models/iot_device_model.dart';
import 'package:duri_care/models/zone_model.dart';
import 'package:duri_care/models/zone_schedule.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for handling all zone-related database operations
class ZoneService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static ZoneService get to => Get.find<ZoneService>();

  /// Initializes the zone service
  Future<ZoneService> init() async {
    return this;
  }

  /// Loads all zones for the current user
  Future<List<ZoneModel>> loadZones(String userId) async {
    final response = await _supabase
        .from('zones')
        .select('*, zone_users!inner(*)')
        .eq('zone_users.user_id', userId)
        .filter('deleted_at', 'is', 'null')
        .order('name', ascending: true);

    return response.map<ZoneModel>((data) {
      final zone = ZoneModel.fromMap(data);
      return zone;
    }).toList();
  }

  /// Loads a specific zone by ID
  Future<ZoneModel> loadZoneById(String zoneId, String userId) async {
    final response =
        await _supabase
            .from('zones')
            .select('*, zone_users!inner(*)')
            .eq('id', zoneId)
            .eq('zone_users.user_id', userId)
            .filter('deleted_at', 'is', null)
            .single();

    return ZoneModel.fromMap(response);
  }

  /// Loads IoT devices for a specific zone
  Future<List<IotDeviceModel>> loadDevicesForZone(String zoneId) async {
    final response = await _supabase
        .from('iot_devices')
        .select()
        .eq('zone_id', zoneId);

    return response
        .map<IotDeviceModel>((data) => IotDeviceModel.fromMap(data))
        .toList();
  }

  /// Loads all IoT devices
  Future<List<IotDeviceModel>> loadAllDevices() async {
    final response = await _supabase
        .from('iot_devices')
        .select('*, zone:zones(*)')
        .order('id', ascending: true);

    return response.map<IotDeviceModel>((data) {
      final Map<String, dynamic> deviceData = {
        'id': data['id'],
        'zone_id': data['zone_id'],
        'iot_code': data['code'] ?? 0,
        'name': data['name'] ?? 'Unknown Device',
      };
      return IotDeviceModel.fromMap(deviceData);
    }).toList();
  }

  /// Creates a new zone
  Future<ZoneModel> createZone({
    required String name,
    required int zoneCode,
    required String userId,
  }) async {
    final existing =
        await _supabase
            .from('zones')
            .select('id')
            .eq('name', name)
            .maybeSingle();

    if (existing != null) {
      throw Exception('Zone with name "$name" already exists');
    }

    final newZone =
        await _supabase
            .from('zones')
            .insert({
              'name': name,
              'isActive': false,
              'zone_code': zoneCode,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    final zoneId = newZone['id']?.toString();
    if (zoneId == null) {
      throw Exception('Failed to get zone ID after creation');
    }

    await _supabase.from('zone_users').insert({
      'zone_id': zoneId,
      'user_id': userId,
    });

    return ZoneModel.fromMap(newZone);
  }

  /// Assigns devices to a zone
  Future<void> assignDevicesToZone(String zoneId, List<int> deviceIds) async {
    final deviceAssignments =
        deviceIds
            .map(
              (deviceId) => {
                'device_id': deviceId,
                'zone_id': zoneId,
                'assigned_at': DateTime.now().toIso8601String(),
              },
            )
            .toList();

    await _supabase.from('zone_devices').insert(deviceAssignments);
  }

  /// Add a device to a zone
  Future<void> addDeviceToZone({
    required String zoneId,
    required int iotCode,
    required String name,
  }) async {
    await _supabase.from('iot_devices').insert({
      'zone_id': zoneId,
      'iot_code': iotCode,
      'name': name,
    });
  }

  /// Deletes a zone (soft delete)
  Future<void> deleteZone(int zoneId) async {
    await _supabase
        .from('zones')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', zoneId);
  }

  /// Updates an existing zone
  Future<ZoneModel> updateZone({
    required String zoneId,
    required String newName,
    required int zoneCode,
  }) async {
    final existing =
        await _supabase
            .from('zones')
            .select('id')
            .eq('name', newName.trim())
            .neq('id', zoneId)
            .maybeSingle();

    if (existing != null) {
      throw Exception('Zone with name "$newName" already exists');
    }

    final updated =
        await _supabase
            .from('zones')
            .update({'name': newName.trim(), 'zone_code': zoneCode})
            .eq('id', zoneId)
            .select()
            .single();

    return ZoneModel.fromMap(updated);
  }

  /// Toggles the active state of a zone
  Future<ZoneModel> toggleZoneActive(dynamic zoneId) async {
    final zone =
        await _supabase
            .from('zones')
            .select('isActive')
            .eq('id', zoneId)
            .single();

    final currentState = zone['isActive'] ?? false;
    final newActiveState = !currentState;

    final updatedZone =
        await _supabase
            .from('zones')
            .update({'isActive': newActiveState})
            .eq('id', zoneId)
            .select()
            .single();

    return ZoneModel.fromMap(updatedZone);
  }

  /// Counts the number of active zones
  Future<int> countActiveZones() async {
    final response = await _supabase
        .from('zones')
        .select('id')
        .eq('isActive', true)
        .filter('deleted_at', 'is', null);

    return response.length;
  }

  /// Creates a new irrigation schedule
  Future<Map<String, dynamic>> createSchedule({
    required DateTime scheduledDateTime,
    required int duration,
    required String zoneId,
  }) async {
    final insertedSchedule =
        await _supabase
            .from('irrigation_schedules')
            .insert({
              'duration': duration,
              'status_id': 1,
              'scheduled_at': scheduledDateTime.toIso8601String(),
              'executed': false,
            })
            .select()
            .single();

    await _supabase.from('zone_schedules').insert({
      'zone_id': int.parse(zoneId),
      'schedule_id': insertedSchedule['id'],
    });

    return insertedSchedule;
  }

  /// Deletes a schedule
  Future<void> deleteSchedule(int scheduleId) async {
    await _supabase.from('irrigation_schedules').delete().eq('id', scheduleId);
  }

  /// Loads all schedules for a specific zone
  Future<List<ZoneScheduleModel>> loadZoneSchedules(String zoneId) async {
    final data = await _supabase
        .from('zone_schedules')
        .select(
          '*, schedule:schedule_id(id, scheduled_at, duration, executed, status_id)',
        )
        .eq('zone_id', zoneId);

    final scheduleList =
        (data as List).map((item) => ZoneScheduleModel.fromMap(item)).toList();

    scheduleList.sort(
      (a, b) => a.schedule.scheduledAt.compareTo(b.schedule.scheduledAt),
    );

    return scheduleList;
  }

  /// Loads all zone schedules across all zones
  Future<List<dynamic>> loadAllZoneSchedules() async {
    final data = await _supabase
        .from('zone_schedules')
        .select(
          '*, zone:zones(*), schedule:schedule_id(id, scheduled_at, duration, executed, status_id)',
        );

    data.sort((a, b) {
      final scheduleA = a['schedule'] as Map<String, dynamic>;
      final scheduleB = b['schedule'] as Map<String, dynamic>;
      final dateA = DateTime.parse(scheduleA['scheduled_at'].toString());
      final dateB = DateTime.parse(scheduleB['scheduled_at'].toString());
      return dateA.compareTo(dateB);
    });

    return data;
  }

  /// Sets up a Supabase stream to listen for zone changes
  Stream<List<Map<String, dynamic>>> zoneChangesStream() {
    return _supabase
        .from('zones')
        .stream(primaryKey: ['id'])
        .map((event) => event);
  }
}
