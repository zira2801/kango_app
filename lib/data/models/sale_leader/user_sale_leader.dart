// Model chính

import 'dart:convert';

UserSaleLeaderResponse userSaleLeaderListFromJson(String str) =>
    UserSaleLeaderResponse.fromJson(json.decode(str));

String userSaleLeaderListToJson(UserSaleLeaderResponse data) =>
    json.encode(data.toJson());

class UserSaleLeaderResponse {
  final int? status;
  final List<UserSaleLeader>? users;

  UserSaleLeaderResponse({this.status, this.users});

  factory UserSaleLeaderResponse.fromJson(Map<String, dynamic> json) {
    return UserSaleLeaderResponse(
      status: json['status'] as int?,
      users: json['users'] != null
          ? (json['users'] as List<dynamic>)
              .map((e) => UserSaleLeader.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'users': users?.map((e) => e.toJson()).toList(),
    };
  }
}

// Model User
class UserSaleLeader {
  final String? userContactName;
  final String? userCode;
  final String? userName;
  final int? userId;

  UserSaleLeader({
    this.userContactName,
    this.userCode,
    this.userName,
    this.userId,
  });

  factory UserSaleLeader.fromJson(Map<String, dynamic> json) {
    return UserSaleLeader(
      userContactName: json['user_contact_name'] as String?,
      userCode: json['user_code'] as String?,
      userName: json['user_name'] as String?,
      userId: _parseUserId(json['user_id']),
    );
  }

  static int? _parseUserId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_contact_name': userContactName,
      'user_code': userCode,
      'user_name': userName,
      'user_id': userId,
    };
  }
}
