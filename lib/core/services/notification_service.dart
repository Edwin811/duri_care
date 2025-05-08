import 'package:duri_care/models/notification_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final supabase = Supabase.instance.client;

  /// Ambil semua notifikasi berdasarkan user ID
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => NotificationModel.fromMap(map))
        .toList();
  }

  /// Tambahkan notifikasi untuk satu user
  Future<void> sendNotificationToUser({
    required String userId,
    required String message,
  }) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'message': message,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Kirim notifikasi ke semua user dalam zona tertentu
  Future<void> notifyUsersInZone({
    required int zoneId,
    required String message,
  }) async {
    final result = await supabase
        .from('zone_users')
        .select('user_id')
        .eq('zone_id', zoneId);

    final users = List<Map<String, dynamic>>.from(result);

    for (var user in users) {
      await sendNotificationToUser(userId: user['user_id'], message: message);
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}
