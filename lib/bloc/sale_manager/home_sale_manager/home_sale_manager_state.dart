part of 'home_sale_manager_bloc.dart';

abstract class SaleManagerState extends Equatable {
  const SaleManagerState();
  @override
  List<Object?> get props => [];
}

//Lấy thông tin trang Dashboard của Sale Manager
class GetHomeSaleManagerStateInitial extends SaleManagerState {}

class GetHomeSaleManagerStateLoading extends SaleManagerState {}

class GetHomeSaleManagerStateSuccess extends SaleManagerState {
  final HomeSaleManager saleDashboard;

  const GetHomeSaleManagerStateSuccess({required this.saleDashboard});

  GetHomeSaleManagerStateSuccess copyWith({HomeSaleManager? saleDashboard}) {
    return GetHomeSaleManagerStateSuccess(
        saleDashboard: saleDashboard ?? this.saleDashboard);
  }

  @override
  List<Object?> get props => [saleDashboard];
}

class GetHomeSaleManagerStateFailure extends SaleManagerState {
  final String message;

  const GetHomeSaleManagerStateFailure({required this.message});

  GetHomeSaleManagerStateFailure copyWith({String? message}) {
    return GetHomeSaleManagerStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Danh sách tean Leader Sale
class GetSaleTeamLeaderStateInitial extends SaleManagerState {}

class GetSaleTeamLeaderStateLoading extends SaleManagerState {}

class GetSaleTeamLeaderStateSuccess extends SaleManagerState {
  final List<SaleTeamLeader> data;
  final int page;
  final bool hasReachedMax;
  const GetSaleTeamLeaderStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetSaleTeamLeaderStateSuccess copyWith({
    List<SaleTeamLeader>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetSaleTeamLeaderStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetSaleTeamLeaderStateFailure extends SaleManagerState {
  final String message;

  const GetSaleTeamLeaderStateFailure({required this.message});

  GetSaleTeamLeaderStateFailure copyWith({String? message}) {
    return GetSaleTeamLeaderStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Lấy danh sách user có thể thêm vào team
class GetUsersSaleLeaderStateInitial extends SaleManagerState {}

class GetUsersSaleLeaderStateLoading extends SaleManagerState {}

class GetUsersSaleLeaderStateSuccess extends SaleManagerState {
  final List<UserSaleLeader> data;
  final int page;
  final bool hasReachedMax;
  const GetUsersSaleLeaderStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetUsersSaleLeaderStateSuccess copyWith({
    List<UserSaleLeader>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetUsersSaleLeaderStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetUsersSaleLeaderStateFailure extends SaleManagerState {
  final String message;

  const GetUsersSaleLeaderStateFailure({required this.message});

  GetUsersSaleLeaderStateFailure copyWith({String? message}) {
    return GetUsersSaleLeaderStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Thêm Memeber vào team
class AddMemberToTeamStateInitial extends SaleManagerState {}

class AddMemberToTeamStateLoading extends SaleManagerState {}

class AddMemberToTeamStateSuccess extends SaleManagerState {
  final String message;

  const AddMemberToTeamStateSuccess({required this.message});

  AddMemberToTeamStateSuccess copyWith({String? message}) {
    return AddMemberToTeamStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class AddMemberToTeamStateFailure extends SaleManagerState {
  final String message;

  const AddMemberToTeamStateFailure({required this.message});

  AddMemberToTeamStateFailure copyWith({String? message}) {
    return AddMemberToTeamStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Thống kê Sale Leader
class GetDetailsSaleLeaderInitial extends SaleManagerState {}

class GetDetailsSaleLeaderLoading extends SaleManagerState {}

class GetDetailsSaleLeaderSuccess extends SaleManagerState {
  final SaleStatisticsResponse saleStatisticsResponse;
  const GetDetailsSaleLeaderSuccess({required this.saleStatisticsResponse});

  GetDetailsSaleLeaderSuccess copyWith(
      {SaleStatisticsResponse? saleStatisticsResponse}) {
    return GetDetailsSaleLeaderSuccess(
        saleStatisticsResponse:
            saleStatisticsResponse ?? this.saleStatisticsResponse);
  }

  @override
  List<Object?> get props => [saleStatisticsResponse];
}

class GetDetailsSaleLeaderFailure extends SaleManagerState {
  final String message;
  const GetDetailsSaleLeaderFailure({required this.message});
  GetDetailsSaleLeaderFailure copyWith({String? message}) {
    return GetDetailsSaleLeaderFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Lấy danh sách Shipment của sale

class GetShipmentsSaleLeaderStateInitial extends SaleManagerState {}

class GetShipmentsSaleLeaderStateLoading extends SaleManagerState {}

class GetShipmentsSaleLeaderStateSuccess extends SaleManagerState {
  final List<ShipmentSaleData> data;
  final int page;
  final bool hasReachedMax;
  const GetShipmentsSaleLeaderStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetShipmentsSaleLeaderStateSuccess copyWith({
    List<ShipmentSaleData>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetShipmentsSaleLeaderStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetShipmentsSaleLeaderStateFailure extends SaleManagerState {
  final String message;

  const GetShipmentsSaleLeaderStateFailure({required this.message});

  GetShipmentsSaleLeaderStateFailure copyWith({String? message}) {
    return GetShipmentsSaleLeaderStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Lấy danh sách Sale hỗ trợ FWD
class GetListSaleSupportFWDStateInitial extends SaleManagerState {}

class GetListSaleSupportFWDStateLoading extends SaleManagerState {}

class GetListSaleSupportFWDStateSuccess extends SaleManagerState {
  final List<UserFwd> data;
  final int page;
  final bool hasReachedMax;
  const GetListSaleSupportFWDStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetListSaleSupportFWDStateSuccess copyWith({
    List<UserFwd>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetListSaleSupportFWDStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetListSaleSupportFWDStateFailure extends SaleManagerState {
  final String message;

  const GetListSaleSupportFWDStateFailure({required this.message});

  GetListSaleSupportFWDStateFailure copyWith({String? message}) {
    return GetListSaleSupportFWDStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Lấy danh sách Fwd chưa liên kết
class GetListFWDNoLinkStateInitial extends SaleManagerState {}

class GetListFWDNoLinkStateLoading extends SaleManagerState {}

class GetListFWDNoLinkStateSuccess extends SaleManagerState {
  final List<UserFwdNoLink> data;
  final int page;
  final bool hasReachedMax;
  const GetListFWDNoLinkStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetListFWDNoLinkStateSuccess copyWith({
    List<UserFwdNoLink>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetListFWDNoLinkStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetListFWDNoLinkStateFailure extends SaleManagerState {
  final String message;

  const GetListFWDNoLinkStateFailure({required this.message});

  GetListFWDNoLinkStateFailure copyWith({String? message}) {
    return GetListFWDNoLinkStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Link FWD to Sale
class LinkFWDToSaleStateInitial extends SaleManagerState {}

class LinkFWDToSaleStateLoading extends SaleManagerState {}

class LinkFWDToSaleStateSuccess extends SaleManagerState {
  final String message;

  const LinkFWDToSaleStateSuccess({required this.message});

  LinkFWDToSaleStateSuccess copyWith({String? message}) {
    return LinkFWDToSaleStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class LinkFWDToSaleStateFailure extends SaleManagerState {
  final String message;

  const LinkFWDToSaleStateFailure({required this.message});

  LinkFWDToSaleStateFailure copyWith({String? message}) {
    return LinkFWDToSaleStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Lấy thông tin FWD hỗ trợ
class GetDetailsFwdSupportInitial extends SaleManagerState {}

class GetDetailsFwdSupportLoading extends SaleManagerState {}

class GetDetailsFwdSupportSuccess extends SaleManagerState {
  final ResponseFwdSupportModel responseFwdSupportModel;
  const GetDetailsFwdSupportSuccess({required this.responseFwdSupportModel});

  GetDetailsFwdSupportSuccess copyWith(
      {ResponseFwdSupportModel? responseFwdSupportModel}) {
    return GetDetailsFwdSupportSuccess(
        responseFwdSupportModel:
            responseFwdSupportModel ?? this.responseFwdSupportModel);
  }

  @override
  List<Object?> get props => [responseFwdSupportModel];
}

class GetDetailsFwdSupportFailure extends SaleManagerState {
  final String message;
  const GetDetailsFwdSupportFailure({required this.message});
  GetDetailsFwdSupportFailure copyWith({String? message}) {
    return GetDetailsFwdSupportFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Lấy danh sách bảng cost
class GetListCostStateInitial extends SaleManagerState {}

class GetListCostStateLoading extends SaleManagerState {}

class GetListCostStateSuccess extends SaleManagerState {
  final List<UserCost> data;
  final int page;
  final bool hasReachedMax;
  const GetListCostStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetListCostStateSuccess copyWith({
    List<UserCost>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetListCostStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetListCostStateFailure extends SaleManagerState {
  final String message;

  const GetListCostStateFailure({required this.message});

  GetListCostStateFailure copyWith({String? message}) {
    return GetListCostStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Lấy danh sách Shipment của FWD
class GetListShipmentFWDStateInitial extends SaleManagerState {}

class GetListShipmentFWDStateLoading extends SaleManagerState {}

class GetListShipmentFWDStateSuccess extends SaleManagerState {
  final List<ShipmentFwdModel> data;
  final int page;
  final bool hasReachedMax;
  const GetListShipmentFWDStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetListShipmentFWDStateSuccess copyWith({
    List<ShipmentFwdModel>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetListShipmentFWDStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetListShipmentFWDStateFailure extends SaleManagerState {
  final String message;

  const GetListShipmentFWDStateFailure({required this.message});

  GetListShipmentFWDStateFailure copyWith({String? message}) {
    return GetListShipmentFWDStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Xóa FWD Company
class DeleteSaleToSupportFWDStateInitial extends SaleManagerState {}

class DeleteSaleToSupportFWDStateLoading extends SaleManagerState {}

class DeleteSaleToSupportFWDStateSuccess extends SaleManagerState {
  final String message;

  const DeleteSaleToSupportFWDStateSuccess({required this.message});

  DeleteSaleToSupportFWDStateSuccess copyWith({String? message}) {
    return DeleteSaleToSupportFWDStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class DeleteSaleToSupportFWDStateFailure extends SaleManagerState {
  final String message;

  const DeleteSaleToSupportFWDStateFailure({required this.message});

  DeleteSaleToSupportFWDStateFailure copyWith({String? message}) {
    return DeleteSaleToSupportFWDStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
//Chức năng chính của Sale Manager của Admin

//Thêm Mới sale leader
class AddLeaderStateInitial extends SaleManagerState {}

class AddLeaderStateLoading extends SaleManagerState {}

class AddLeaderStateSuccess extends SaleManagerState {
  final String message;

  const AddLeaderStateSuccess({required this.message});

  AddLeaderStateSuccess copyWith({String? message}) {
    return AddLeaderStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class AddLeaderStateFailure extends SaleManagerState {
  final String message;

  const AddLeaderStateFailure({required this.message});

  AddLeaderStateFailure copyWith({String? message}) {
    return AddLeaderStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Thêm Member vào Team Sale Leader
class AddMemberToTeamSaleStateInitial extends SaleManagerState {}

class AddMemberToTeamSaleStateLoading extends SaleManagerState {}

class AddMemberToTeamSaleStateSuccess extends SaleManagerState {
  final String message;

  const AddMemberToTeamSaleStateSuccess({required this.message});

  AddMemberToTeamSaleStateSuccess copyWith({String? message}) {
    return AddMemberToTeamSaleStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class AddMemberToTeamSaleStateFailure extends SaleManagerState {
  final String message;

  const AddMemberToTeamSaleStateFailure({required this.message});

  AddMemberToTeamSaleStateFailure copyWith({String? message}) {
    return AddMemberToTeamSaleStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Cập nhật trạng thái thành viên trong team
class UpdateStatusMemeberStateInitial extends SaleManagerState {}

class UpdateStatusMemeberStateLoading extends SaleManagerState {}

class UpdateStatusMemeberStateSuccess extends SaleManagerState {
  final String message;

  const UpdateStatusMemeberStateSuccess({required this.message});

  UpdateStatusMemeberStateSuccess copyWith({String? message}) {
    return UpdateStatusMemeberStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class UpdateStatusMemeberStateFailure extends SaleManagerState {
  final String message;

  const UpdateStatusMemeberStateFailure({required this.message});

  UpdateStatusMemeberStateFailure copyWith({String? message}) {
    return UpdateStatusMemeberStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Cập nhật trạng thái thành viên trong team
class TransferMemberToTeamStateInitial extends SaleManagerState {}

class TransferMemberToTeamStateLoading extends SaleManagerState {}

class TransferMemberToTeamStateSuccess extends SaleManagerState {
  final String message;

  const TransferMemberToTeamStateSuccess({required this.message});

  TransferMemberToTeamStateSuccess copyWith({String? message}) {
    return TransferMemberToTeamStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class TransferMemberToTeamStateFailure extends SaleManagerState {
  final String message;

  const TransferMemberToTeamStateFailure({required this.message});

  TransferMemberToTeamStateFailure copyWith({String? message}) {
    return TransferMemberToTeamStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

//Xóa Team Sale
class DeleteTeamSaleStateInitial extends SaleManagerState {}

class DeleteTeamSaleStateLoading extends SaleManagerState {}

class DeleteTeamSaleStateSuccess extends SaleManagerState {
  final String message;

  const DeleteTeamSaleStateSuccess({required this.message});

  DeleteTeamSaleStateSuccess copyWith({String? message}) {
    return DeleteTeamSaleStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class DeleteTeamSaleStateFailure extends SaleManagerState {
  final String message;

  const DeleteTeamSaleStateFailure({required this.message});

  DeleteTeamSaleStateFailure copyWith({String? message}) {
    return DeleteTeamSaleStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
