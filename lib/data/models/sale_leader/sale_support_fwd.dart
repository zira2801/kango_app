import 'dart:convert';

SaleSupportFWDResponse fwdListFromJson(String str) =>
    SaleSupportFWDResponse.fromJson(json.decode(str));

String fwdListToJson(SaleSupportFWDResponse data) => json.encode(data.toJson());

class SaleSupportFWDResponse {
  final int status;
  final List<UserFwd> users;

  SaleSupportFWDResponse({
    required this.status,
    required this.users,
  });

  factory SaleSupportFWDResponse.fromJson(Map<String, dynamic> json) {
    return SaleSupportFWDResponse(
      status: json['status'] ?? 0,
      users: (json['users'] as List<dynamic>?)
              ?.map((userJson) => UserFwd.fromJson(userJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}

class UserFwd {
  final int userId;
  final String userCode;
  final String userContactName;
  final int? saleTeamId;
  final List<MemberFwd> members;
  final List<CompanyFwd> companies;

  UserFwd({
    required this.userId,
    required this.userCode,
    required this.userContactName,
    this.saleTeamId,
    required this.members,
    required this.companies,
  });

  factory UserFwd.fromJson(Map<String, dynamic> json) {
    return UserFwd(
      userId: json['user_id'] ?? 0,
      userCode: json['user_code'] ?? '',
      userContactName: json['user_contact_name'] ?? '',
      saleTeamId: json['sale_team_id'],
      members: (json['members'] as List<dynamic>?)
              ?.map((memberJson) => MemberFwd.fromJson(memberJson))
              .toList() ??
          [],
      companies: (json['companies'] as List<dynamic>?)
              ?.map((companyJson) => CompanyFwd.fromJson(companyJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_code': userCode,
      'user_contact_name': userContactName,
      'sale_team_id': saleTeamId,
      'members': members.map((member) => member.toJson()).toList(),
      'companies': companies.map((company) => company.toJson()).toList(),
    };
  }
}

class MemberFwd {
  final int userId;
  final String userCode;
  final String userContactName;
  final List<CompanyFwd> companies;

  MemberFwd({
    required this.userId,
    required this.userCode,
    required this.userContactName,
    required this.companies,
  });

  factory MemberFwd.fromJson(Map<String, dynamic> json) {
    return MemberFwd(
      userId: json['user_id'] ?? 0,
      userCode: json['user_code'] ?? '',
      userContactName: json['user_contact_name'] ?? '',
      companies: (json['companies'] as List<dynamic>?)
              ?.map((companyJson) => CompanyFwd.fromJson(companyJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_code': userCode,
      'user_contact_name': userContactName,
      'companies': companies.map((company) => company.toJson()).toList(),
    };
  }
}

class CompanyFwd {
  final int? saleLinkFwdId;
  final int? fwdId;
  final String userCompanyName;
  final String userContactName;
  final String userCode;
  final double? totalWeight;

  CompanyFwd({
    this.saleLinkFwdId,
    this.fwdId,
    required this.userCompanyName,
    required this.userContactName,
    required this.userCode,
    this.totalWeight,
  });

  factory CompanyFwd.fromJson(Map<String, dynamic> json) {
    return CompanyFwd(
      saleLinkFwdId: json['sale_link_fwd_id'],
      fwdId: json['fwd_id'],
      userCompanyName: json['user_company_name'] ?? '',
      userContactName: json['user_contact_name'] ?? '',
      userCode: json['user_code'] ?? '',
      totalWeight: json['total_weight'] != null
          ? double.tryParse(json['total_weight'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_link_fwd_id': saleLinkFwdId,
      'fwd_id': fwdId,
      'user_company_name': userCompanyName,
      'user_contact_name': userContactName,
      'user_code': userCode,
      'total_weight': totalWeight,
    };
  }
}
