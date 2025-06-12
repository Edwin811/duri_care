import 'package:duri_care/models/notification_model.dart';
import 'package:duri_care/core/services/connectivity_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final supabase = Supabase.instance.client;
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    if (!await _connectivity.hasInternetConnection()) {
      return <NotificationModel>[];
    }

    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => NotificationModel.fromMap(map))
        .toList();
  }

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

  Future<void> markNotificationAsRead(int notificationId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> deleteNotification(int notificationId) async {
    await supabase.from('notifications').delete().eq('id', notificationId);
  }
}
