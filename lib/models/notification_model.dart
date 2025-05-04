class NotificationModel {
  final int id;
  final String userId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      message: map['message'],
      isRead: map['is_read'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
