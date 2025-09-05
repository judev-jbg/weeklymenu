/// Modelo para las notificaciones del usuario
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? dailyMenuId;
  final bool isRead;
  final DateTime sentAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.dailyMenuId,
    required this.isRead,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      dailyMenuId: json['daily_menu_id'] as String?,
      isRead: json['is_read'] as bool,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'daily_menu_id': dailyMenuId,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      dailyMenuId: dailyMenuId,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
    );
  }

  /// Obtiene el tiempo relativo desde que se envió
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}
