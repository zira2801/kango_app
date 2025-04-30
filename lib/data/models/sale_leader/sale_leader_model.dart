class SaleResponse {
  final int? status;
  final bool? isSale;
  final LeaderInfo? isLeader;
  final int? leaderId;

  SaleResponse({
    this.status,
    this.isSale,
    this.isLeader,
    this.leaderId,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      status: json['status'] as int?,
      isSale: json['is_sale'] as bool?,
      isLeader: json['is_leader'] != null
          ? LeaderInfo.fromJson(json['is_leader'])
          : null,
      leaderId: json['leader_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'is_sale': isSale,
      'is_leader': isLeader?.toJson(),
      'leader_id': leaderId,
    };
  }
}

class LeaderInfo {
  final int? saleTeamId;
  final String? saleTeamCode;
  final int? leaderId;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaderInfo({
    this.saleTeamId,
    this.saleTeamCode,
    this.leaderId,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaderInfo.fromJson(Map<String, dynamic> json) {
    return LeaderInfo(
      saleTeamId: json['sale_team_id'] as int?,
      saleTeamCode: json['sale_team_code'] as String?,
      leaderId: json['leader_id'] as int?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_team_id': saleTeamId,
      'sale_team_code': saleTeamCode,
      'leader_id': leaderId,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
