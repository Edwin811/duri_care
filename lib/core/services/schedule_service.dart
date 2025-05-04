import 'package:duri_care/models/irrigation_schedule.dart';
import 'package:duri_care/models/upcomingschedule.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Upcomingschedule?> getUpcomingScheduleWithZone() async {
    try {
      final now = DateTime.now().toIso8601String();

      final data =
          await _supabase
              .from('zone_schedules')
              .select(
                'schedule:schedule_id(id, scheduled_at, duration, executed, status_id), zone:zone_id(name)',
              )
              .gte('schedule.scheduled_at', now)
              .order('schedule.scheduled_at', ascending: true)
              .limit(1)
              .maybeSingle();

      if (data == null) return null;

      final scheduleData = data['schedule'];
      final zoneData = data['zone'];

      if (scheduleData == null || zoneData == null) return null;

      final schedule = IrrigationScheduleModel.fromMap(scheduleData);
      final zoneName = zoneData['name'] ?? 'Tanpa Nama';

      return Upcomingschedule(schedule: schedule, zoneName: zoneName);
    } catch (e) {
      return null;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String formatScheduleWithZone(Upcomingschedule info) {
    final schedule = info.schedule;
    final start = schedule.scheduledAt;
    final end = start.add(Duration(minutes: schedule.duration));

    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final dayName = days[start.weekday - 1];

    final datePart = '${start.day} ${_monthName(start.month)} ${start.year}';
    final timePart = '${_formatTime(start)} - ${_formatTime(end)} WIB';

    return '$dayName, $datePart | $timePart [${info.zoneName}]';
  }
}
