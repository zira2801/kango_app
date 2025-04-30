part of 'home_sale_manager_bloc.dart';

abstract class SaleManagerEvent extends Equatable {
  const SaleManagerEvent();

  @override
  List<Object?> get props => [];
}

class GetHomeSaleManager extends SaleManagerEvent {
  const GetHomeSaleManager();
  @override
  List<Object?> get props => [];
}

class GetSaleTeamLeader extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;
  const GetSaleTeamLeader({
    this.startDate,
    this.endDate,
    this.keywords,
  });
  @override
  List<Object?> get props => [startDate, endDate, keywords];
}

class LoadMoreSaleTeamLeader extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;
  const LoadMoreSaleTeamLeader({
    this.startDate,
    this.endDate,
    this.keywords,
  });
  @override
  List<Object?> get props => [startDate, endDate, keywords];
}

//Event Lấy danh sách user có thể thêm vào team
class GetUsersSaleLeader extends SaleManagerEvent {
  final String? keywords;
  final String? positionName;
  final List<int>? userNotIn;

  const GetUsersSaleLeader({
    this.keywords,
    this.positionName,
    this.userNotIn,
  });

  @override
  List<Object?> get props => [keywords, positionName, userNotIn];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'paginate': {
  //       'limit': limit,
  //       'page': page,
  //     },
  //     'filters': {
  //       'keywords': keywords,
  //     },
  //     'position_name': positionName,
  //     'user_not_in': userNotIn,
  //   };
  // }
}

class LoadMoreUsersSaleLeader extends SaleManagerEvent {
  final String? keywords;
  final String? positionName;
  final List<int>? userNotIn;

  const LoadMoreUsersSaleLeader({
    this.keywords,
    this.positionName,
    this.userNotIn,
  });

  @override
  List<Object?> get props => [keywords, positionName, userNotIn];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'paginate': {
  //       'limit': limit,
  //       'page': page,
  //     },
  //     'filters': {
  //       'keywords': keywords,
  //     },
  //     'position_name': positionName,
  //     'user_not_in': userNotIn,
  //   };
  // }
}

//Thêm member vào team
class AddMemberToTeam extends SaleManagerEvent {
  final List<int> userIds;
  final int leaderId;

  const AddMemberToTeam({
    required this.userIds,
    required this.leaderId,
  });

  @override
  List<Object?> get props => [userIds, leaderId];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}

//Lấy thống kê sale leader
class GetDetailSaleLeader extends SaleManagerEvent {
  final String? saleCode;
  final String? monthDate;
  const GetDetailSaleLeader({
    required this.saleCode,
    required this.monthDate,
  });
  @override
  List<Object?> get props => [saleCode, monthDate];
}

//Lấy danh sách shipment sale
class GetShipmentSale extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final int? userId;
  final String? keywords;
  const GetShipmentSale({
    this.userId,
    this.keywords,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [userId, keywords, startDate, endDate];
}

class LoadMoreShipmentSale extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final int? userId;
  final String? keywords;
  const LoadMoreShipmentSale({
    this.userId,
    this.keywords,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [userId, keywords, startDate, endDate];
}

//Lấy danh sách sale hỗ trợ FWD

class GetSaleSupportFWD extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;
  const GetSaleSupportFWD({
    this.keywords,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [keywords, startDate, endDate];
}

class LoadMoreSaleSupportFWD extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;
  const LoadMoreSaleSupportFWD({
    this.keywords,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [keywords, startDate, endDate];
}

//Lấy danh sách FWD chưa liên kết
class GetListFWDNoLink extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final int? companyID;
  const GetListFWDNoLink({
    this.companyID,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [companyID, startDate, endDate];
}

class LoadMoreListFWDNoLink extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final int? companyID;
  const LoadMoreListFWDNoLink({
    this.companyID,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [companyID, startDate, endDate];
}

//Thêm member vào team
class LinkFWDToSale extends SaleManagerEvent {
  final List<int>? fwdIds;
  final int saleId;

  const LinkFWDToSale({
    required this.fwdIds,
    required this.saleId,
  });

  @override
  List<Object?> get props => [fwdIds, saleId];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}

class GetDetailFwdSupport extends SaleManagerEvent {
  final String companyCode;

  const GetDetailFwdSupport({required this.companyCode});

  @override
  List<Object?> get props => [companyCode];
}

//Lấy danh sách bảng áp giá code cho từng dịch vụ
class GetListCodeFWD extends SaleManagerEvent {
  final int? companyID;
  const GetListCodeFWD({this.companyID});
  @override
  List<Object?> get props => [companyID];
}

class LoadMoreListCostFWD extends SaleManagerEvent {
  final int? companyID;
  const LoadMoreListCostFWD({this.companyID});
  @override
  List<Object?> get props => [companyID];
}

//Lấy danh sách Shipment FWD

class GetShipmentFWD extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;
  final int? userID;
  const GetShipmentFWD(
      {this.keywords, this.startDate, this.endDate, this.userID});
  @override
  List<Object?> get props => [keywords, startDate, endDate, userID];
}

class LoadMoreShipmentFWD extends SaleManagerEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;
  final int? userID;
  const LoadMoreShipmentFWD(
      {this.keywords, this.startDate, this.endDate, this.userID});
  @override
  List<Object?> get props => [keywords, startDate, endDate, userID];
}

//Xóa FWD Company
class DeleteSaleSupportFWD extends SaleManagerEvent {
  final int keyID;

  const DeleteSaleSupportFWD({
    required this.keyID,
  });

  @override
  List<Object?> get props => [keyID];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}
//Chức năng Sale Manager của Admin

//Thêm member vào team
class AddLeader extends SaleManagerEvent {
  final List<int> userIds;

  const AddLeader({
    required this.userIds,
  });

  @override
  List<Object?> get props => [userIds];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}

//Thêm Member vào Team Sale Leader
class AddMemberToTeamSale extends SaleManagerEvent {
  final List<int> userIds;
  final int saleTeamId;

  const AddMemberToTeamSale({
    required this.userIds,
    required this.saleTeamId,
  });

  @override
  List<Object?> get props => [userIds, saleTeamId];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}

//Cập nhật trạng thái thành viên trong team
class UpdateStatusMember extends SaleManagerEvent {
  final int teamId;
  final int memberID;
  final int kind;

  const UpdateStatusMember(
      {required this.teamId, required this.memberID, required this.kind});

  @override
  List<Object?> get props => [teamId, memberID, kind];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}

//Chuyển member sang team khác
class TransferMemberToTeam extends SaleManagerEvent {
  final int teamId;
  final int memberID;

  const TransferMemberToTeam({required this.teamId, required this.memberID});

  @override
  List<Object?> get props => [teamId, memberID];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}

//Chuyển member sang team khác
class DeleteTeamSale extends SaleManagerEvent {
  final int teamId;

  const DeleteTeamSale({required this.teamId});

  @override
  List<Object?> get props => [teamId];

  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_ids': userIds,
  //     'leader_id': leaderId,
  //   };
  // }
}
