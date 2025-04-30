import 'dart:convert';

SaleLeaderListResponse saleLeaderListFromJson(String str) =>
    SaleLeaderListResponse.fromJson(json.decode(str));

String saleLeaderListToJson(SaleLeaderListResponse data) =>
    json.encode(data.toJson());

class SaleLeaderListResponse {
  final int? status;
  final List<SaleTeamLeader>? teams;
  final bool? checkEdit;
  final dynamic filters;

  SaleLeaderListResponse(
      {this.status, this.teams, this.checkEdit, this.filters});

  factory SaleLeaderListResponse.fromJson(Map<String, dynamic> json) {
    return SaleLeaderListResponse(
      status: json['status'] as int?,
      teams: (json['teams'] as List?)
          ?.map((e) => SaleTeamLeader.fromJson(e))
          .toList(),
      checkEdit: json['check_edit'] as bool?,
      filters: json['filters'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'teams': teams?.map((e) => e.toJson()).toList(),
      'check_edit': checkEdit,
      'filters': filters,
    };
  }
}

class SaleTeamLeader {
  final String? userContactName;
  final String? userCode;
  final int? saleTeamId;
  final String? createdAt;
  final List<Member>? members;

  SaleTeamLeader(
      {this.userContactName,
      this.userCode,
      this.saleTeamId,
      this.createdAt,
      this.members});

  factory SaleTeamLeader.fromJson(Map<String, dynamic> json) {
    return SaleTeamLeader(
      userContactName: json['user_contact_name'] as String?,
      userCode: json['user_code'] as String?,
      saleTeamId: json['sale_team_id'] as int?,
      createdAt: json['created_at'] as String?,
      members:
          (json['members'] as List?)?.map((e) => Member.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_contact_name': userContactName,
      'user_code': userCode,
      'sale_team_id': saleTeamId,
      'created_at': createdAt,
      'members': members?.map((e) => e.toJson()).toList(),
    };
  }
}

class Member {
  final int? saleMemberId;
  final int? memberKind;
  final String? userContactName;
  final int? userId;
  final String? userCode;
  final int? memberProfit;

  Member(
      {this.saleMemberId,
      this.memberKind,
      this.userContactName,
      this.userId,
      this.userCode,
      this.memberProfit});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      saleMemberId: json['sale_member_id'] as int?,
      memberKind: json['member_kind'] as int?,
      userContactName: json['user_contact_name'] as String?,
      userId: json['user_id'] as int?,
      userCode: json['user_code'] as String?,
      memberProfit: json['member_profit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_member_id': saleMemberId,
      'member_kind': memberKind,
      'user_contact_name': userContactName,
      'user_id': userId,
      'user_code': userCode,
      'member_profit': memberProfit,
    };
  }
}
