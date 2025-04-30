class UserCostResponse {
  final int? status;
  final List<UserCost>? users;

  UserCostResponse({
    this.status,
    this.users,
  });

  factory UserCostResponse.fromJson(Map<String, dynamic> json) {
    return UserCostResponse(
      status: json['status'] as int?,
      users: json['users'] != null
          ? (json['users'] as List)
              .map((user) => UserCost.fromJson(user as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'users': users?.map((user) => user.toJson()).toList(),
    };
  }
}

class UserCost {
  final int? fwdCostId;
  final int? fwdId;
  final int? serviceId;
  final int? leaderId;
  final int? leaderCost;
  final int? memberCost;
  final int? leaderMemberCost;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userCompanyName;
  final String? userCode;
  final String? serviceName;

  UserCost({
    this.fwdCostId,
    this.fwdId,
    this.serviceId,
    this.leaderId,
    this.leaderCost,
    this.memberCost,
    this.leaderMemberCost,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.userCompanyName,
    this.userCode,
    this.serviceName,
  });

  factory UserCost.fromJson(Map<String, dynamic> json) {
    return UserCost(
      fwdCostId: json['fwd_cost_id'] as int?,
      fwdId: json['fwd_id'] as int?,
      serviceId: json['service_id'] as int?,
      leaderId: json['leader_id'] as int?,
      leaderCost: json['leader_cost'] as int?,
      memberCost: json['member_cost'] as int?,
      leaderMemberCost: json['leader_member_cost'] as int?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      userCompanyName: json['user_company_name'] as String?,
      userCode: json['user_code'] as String?,
      serviceName: json['service_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fwd_cost_id': fwdCostId,
      'fwd_id': fwdId,
      'service_id': serviceId,
      'leader_id': leaderId,
      'leader_cost': leaderCost,
      'member_cost': memberCost,
      'leader_member_cost': leaderMemberCost,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_company_name': userCompanyName,
      'user_code': userCode,
      'service_name': serviceName,
    };
  }
}
