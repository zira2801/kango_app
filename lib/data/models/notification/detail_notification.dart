import 'dart:convert';

class DetailNotification {
  final int status;
  final NotificationModel data;
  DetailNotification({required this.status, required this.data});

  factory DetailNotification.fromJson(Map<String, dynamic> json) {
    return DetailNotification(
        status: json['status'],
        data: NotificationModel.fromJson(json['notification']));
  }
  Map<String, dynamic> toJson() {
    return {'staus': status, 'notification': data.toJson()};
  }
}

class NotificationModel {
  final int notificationId;
  final int userId;
  final String notificationTitle;
  final String notificationContent;
  final String? notificationFile;
  final int notificationImportant;
  final int activeFlg;
  final int deleteFlg;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.notificationTitle,
    required this.notificationContent,
    this.notificationFile,
    required this.notificationImportant,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ Convert JSON → Model
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] as int,
      userId: json['user_id'] as int,
      notificationTitle: json['notification_title'] as String,
      notificationContent: json['notification_content'] as String,
      notificationFile: json['notification_file'], // Có thể null
      notificationImportant: json['notification_important'] as int,
      activeFlg: json['active_flg'] as int,
      deleteFlg: json['delete_flg'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// ✅ Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'notification_title': notificationTitle,
      'notification_content': notificationContent,
      'notification_file': notificationFile,
      'notification_important': notificationImportant,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// ✅ Convert JSON String → Model
  static NotificationModel fromJsonString(String jsonString) {
    return NotificationModel.fromJson(jsonDecode(jsonString));
  }

  /// ✅ Convert Model → JSON String
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
