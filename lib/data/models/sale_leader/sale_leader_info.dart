import 'dart:convert';

SaleStatisticsResponse saleStatisticsFromJson(String str) =>
    SaleStatisticsResponse.fromJson(json.decode(str));

String saleStatisticsToJson(SaleStatisticsResponse data) =>
    json.encode(data.toJson());

class SaleStatisticsResponse {
  final int? status;
  final InfoSale? infoSale;
  final SaleStatistic? saleStatistic;
  final KPI? kpi;
  final bool? isLeader;
  final List<SaleTeamMember>? saleTeam;
  final TotalTeam? totalTeam;
  final String? monthDate;
  final bool? isGetAll;

  SaleStatisticsResponse({
    this.status,
    this.infoSale,
    this.saleStatistic,
    this.kpi,
    this.isLeader,
    this.saleTeam,
    this.totalTeam,
    this.monthDate,
    this.isGetAll,
  });

  factory SaleStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return SaleStatisticsResponse(
      status: json['status'],
      infoSale: json['info_sale'] != null
          ? InfoSale.fromJson(json['info_sale'])
          : null,
      saleStatistic: json['sale_statistic'] != null
          ? SaleStatistic.fromJson(json['sale_statistic'])
          : null,
      kpi: json['kpi'] != null ? KPI.fromJson(json['kpi']) : null,
      isLeader: json['is_leader'],
      saleTeam: json['sale_team'] != null
          ? List<SaleTeamMember>.from(
              json['sale_team'].map((x) => SaleTeamMember.fromJson(x)))
          : null,
      totalTeam: json['total_team'] != null
          ? TotalTeam.fromJson(json['total_team'])
          : null,
      monthDate: json['monthDate'],
      isGetAll: json['is_get_all'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    if (infoSale != null) {
      data['info_sale'] = infoSale!.toJson();
    }
    if (saleStatistic != null) {
      data['sale_statistic'] = saleStatistic!.toJson();
    }
    if (kpi != null) {
      data['kpi'] = kpi!.toJson();
    }
    data['is_leader'] = isLeader;
    if (saleTeam != null) {
      data['sale_team'] = saleTeam!.map((x) => x.toJson()).toList();
    }
    if (totalTeam != null) {
      data['total_team'] = totalTeam!.toJson();
    }
    data['monthDate'] = monthDate;
    data['is_get_all'] = isGetAll;
    return data;
  }
}

class InfoSale {
  final int? userId;
  final String? userContactName;
  final String? userCode;
  final String? userName;
  final String? userPhone;
  final bool? isLeader;
  final String? createdAt;
  final RangeKPI? rangeKPI;

  InfoSale({
    this.userId,
    this.userContactName,
    this.userCode,
    this.userName,
    this.userPhone,
    this.isLeader,
    this.createdAt,
    this.rangeKPI,
  });

  factory InfoSale.fromJson(Map<String, dynamic> json) {
    return InfoSale(
      userId: json['user_id'],
      userContactName: json['user_contact_name'],
      userCode: json['user_code'],
      userName: json['user_name'],
      userPhone: json['user_phone'],
      isLeader: json['is_leader'],
      createdAt: json['created_at'],
      rangeKPI: json['range_kpi'] != null
          ? RangeKPI.fromJson(json['range_kpi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user_id'] = userId;
    data['user_contact_name'] = userContactName;
    data['user_code'] = userCode;
    data['user_name'] = userName;
    data['user_phone'] = userPhone;
    data['is_leader'] = isLeader;
    data['created_at'] = createdAt;
    if (rangeKPI != null) {
      data['range_kpi'] = rangeKPI!.toJson();
    }
    return data;
  }
}

class RangeKPI {
  final int? rangeKpiId;
  final int? saleKpiId;
  final String? rangeKpiName;
  final int? salary;
  final int? profitStart;
  final int? profitEnd;
  final int? ratioCommission;
  final int? leaderHaveCommission;
  final int? activeFlg;
  final int? deleteFlg;
  final String? createdAt;
  final String? updatedAt;

  RangeKPI({
    this.rangeKpiId,
    this.saleKpiId,
    this.rangeKpiName,
    this.salary,
    this.profitStart,
    this.profitEnd,
    this.ratioCommission,
    this.leaderHaveCommission,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
  });

  factory RangeKPI.fromJson(Map<String, dynamic> json) {
    return RangeKPI(
      rangeKpiId: json['range_kpi_id'],
      saleKpiId: json['sale_kpi_id'],
      rangeKpiName: json['range_kpi_name'],
      salary: json['salary'],
      profitStart: json['profit_start'],
      profitEnd: json['profit_end'],
      ratioCommission: json['ratio_commission'],
      leaderHaveCommission: json['leader_have_commission'],
      activeFlg: json['active_flg'],
      deleteFlg: json['delete_flg'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['range_kpi_id'] = rangeKpiId;
    data['sale_kpi_id'] = saleKpiId;
    data['range_kpi_name'] = rangeKpiName;
    data['salary'] = salary;
    data['profit_start'] = profitStart;
    data['profit_end'] = profitEnd;
    data['ratio_commission'] = ratioCommission;
    data['leader_have_commission'] = leaderHaveCommission;
    data['active_flg'] = activeFlg;
    data['delete_flg'] = deleteFlg;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class SaleStatistic {
  final int? totalShipment;
  final dynamic totalChargedWeight; // Có thể null hoặc số
  final int? totalAmountCustomer;
  final int? totalAmountProfit;
  final int? rangeKpiId;
  final String? rangeKpiName;
  final int? salary;
  final int? ratioCommission;
  final int? commissionAmount;
  final int? costFwdWeight;
  final int? costFwdAmount;
  final int? weightFwd;
  final int? amountFwd;
  final int? finalSalarySale;
  final int? commissionLeaderTeam;
  final int? fwWeightCostLeaderTeam;

  SaleStatistic({
    this.totalShipment,
    this.totalChargedWeight,
    this.totalAmountCustomer,
    this.totalAmountProfit,
    this.rangeKpiId,
    this.rangeKpiName,
    this.salary,
    this.ratioCommission,
    this.commissionAmount,
    this.costFwdWeight,
    this.costFwdAmount,
    this.weightFwd,
    this.amountFwd,
    this.finalSalarySale,
    this.commissionLeaderTeam,
    this.fwWeightCostLeaderTeam,
  });

  factory SaleStatistic.fromJson(Map<String, dynamic> json) {
    return SaleStatistic(
      totalShipment: json['total_shipment'],
      totalChargedWeight: json['total_charged_weight'],
      totalAmountCustomer: json['total_amount_customer'],
      totalAmountProfit: json['total_amount_profit'],
      rangeKpiId: json['range_kpi_id'],
      rangeKpiName: json['range_kpi_name'],
      salary: json['salary'],
      ratioCommission: json['ratio_commission'],
      commissionAmount: json['commission_amount'],
      costFwdWeight: json['cost_fwd_weight'],
      costFwdAmount: json['cost_fwd_amount'],
      weightFwd: json['weight_fwd'],
      amountFwd: json['amount_fwd'],
      finalSalarySale: json['final_salary_sale'],
      commissionLeaderTeam: json['commission_leader_team'],
      fwWeightCostLeaderTeam: json['fw_weight_cost_leader_team'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total_shipment'] = totalShipment;
    data['total_charged_weight'] = totalChargedWeight;
    data['total_amount_customer'] = totalAmountCustomer;
    data['total_amount_profit'] = totalAmountProfit;
    data['range_kpi_id'] = rangeKpiId;
    data['range_kpi_name'] = rangeKpiName;
    data['salary'] = salary;
    data['ratio_commission'] = ratioCommission;
    data['commission_amount'] = commissionAmount;
    data['cost_fwd_weight'] = costFwdWeight;
    data['cost_fwd_amount'] = costFwdAmount;
    data['weight_fwd'] = weightFwd;
    data['amount_fwd'] = amountFwd;
    data['final_salary_sale'] = finalSalarySale;
    data['commission_leader_team'] = commissionLeaderTeam;
    data['fw_weight_cost_leader_team'] = fwWeightCostLeaderTeam;
    return data;
  }
}

class KPI {
  final int? saleKpiId;
  final String? kpiName;
  final int? kpiKind;
  final int? timeKind;
  final String? timeStart;
  final String? timeEnd;
  final dynamic userId; // Có thể null
  final int? activeFlg;
  final int? deleteFlg;
  final String? createdAt;
  final String? updatedAt;
  final List<RangeKPI>? rangeKpis;

  KPI({
    this.saleKpiId,
    this.kpiName,
    this.kpiKind,
    this.timeKind,
    this.timeStart,
    this.timeEnd,
    this.userId,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.rangeKpis,
  });

  factory KPI.fromJson(Map<String, dynamic> json) {
    return KPI(
      saleKpiId: json['sale_kpi_id'],
      kpiName: json['kpi_name'],
      kpiKind: json['kpi_kind'],
      timeKind: json['time_kind'],
      timeStart: json['time_start'],
      timeEnd: json['time_end'],
      userId: json['user_id'],
      activeFlg: json['active_flg'],
      deleteFlg: json['delete_flg'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      rangeKpis: json['range_kpis'] != null
          ? List<RangeKPI>.from(
              json['range_kpis'].map((x) => RangeKPI.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['sale_kpi_id'] = saleKpiId;
    data['kpi_name'] = kpiName;
    data['kpi_kind'] = kpiKind;
    data['time_kind'] = timeKind;
    data['time_start'] = timeStart;
    data['time_end'] = timeEnd;
    data['user_id'] = userId;
    data['active_flg'] = activeFlg;
    data['delete_flg'] = deleteFlg;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (rangeKpis != null) {
      data['range_kpis'] = rangeKpis!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}

class SaleTeamMember {
  final int? memberKind;
  final String? userCode;
  final String? userContactName;
  final int? userId;
  final dynamic userKpiId; // Có thể null
  final String? createdAt;
  final int? salary;
  final int? ratioCommission;
  final String? rangeKpiName;
  final int? totalProfit;
  final int? totalWeight;
  final int? fwdCost;
  final String? note;

  SaleTeamMember(
      {this.memberKind,
      this.userCode,
      this.userContactName,
      this.userId,
      this.userKpiId,
      this.createdAt,
      this.salary,
      this.ratioCommission,
      this.rangeKpiName,
      this.totalProfit,
      this.totalWeight,
      this.fwdCost,
      t,
      this.note});

  factory SaleTeamMember.fromJson(Map<String, dynamic> json) {
    return SaleTeamMember(
        memberKind: json['member_kind'],
        userCode: json['user_code'],
        userContactName: json['user_contact_name'],
        userId: json['user_id'],
        userKpiId: json['user_kpi_id'],
        createdAt: json['created_at'],
        salary: json['salary'],
        ratioCommission: json['ratio_commission'],
        rangeKpiName: json['range_kpi_name'],
        totalProfit: json['total_profit'],
        totalWeight: json['total_weight'],
        fwdCost: json['fwd_cost'],
        note: json['note']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_kind'] = memberKind;
    data['user_code'] = userCode;
    data['user_contact_name'] = userContactName;
    data['user_id'] = userId;
    data['user_kpi_id'] = userKpiId;
    data['created_at'] = createdAt;
    data['salary'] = salary;
    data['ratio_commission'] = ratioCommission;
    data['range_kpi_name'] = rangeKpiName;
    data['total_profit'] = totalProfit;
    data['total_weight'] = totalWeight;
    data['fwd_cost'] = fwdCost;
    data['note'] = note;
    return data;
  }
}

class TotalTeam {
  final int? teamProfit;
  final int? teamFwdWeight;
  final int? teamFwdCost;

  TotalTeam({
    this.teamProfit,
    this.teamFwdWeight,
    this.teamFwdCost,
  });

  factory TotalTeam.fromJson(Map<String, dynamic> json) {
    return TotalTeam(
      teamProfit: json['team_profit'],
      teamFwdWeight: json['team_fwd_weight'],
      teamFwdCost: json['team_fwd_cost'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['team_profit'] = teamProfit;
    data['team_fwd_weight'] = teamFwdWeight;
    data['team_fwd_cost'] = teamFwdCost;
    return data;
  }
}
