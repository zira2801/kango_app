part of 'audit_epacket_bloc.dart';

abstract class HandleGetAuditEpacketState extends Equatable {
  const HandleGetAuditEpacketState();
  @override
  List<Object?> get props => [];
}

class HandleGetAuditEpacketStateInitial extends HandleGetAuditEpacketState {}

class HandleGetAuditEpacketStateloading extends HandleGetAuditEpacketState {}

class HandleGetAuditEpacketStateSuccess extends HandleGetAuditEpacketState {
  final List<ShipmentAuditEpacket> data;
  final int page;
  final bool hasReachedMax;
  const HandleGetAuditEpacketStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  HandleGetAuditEpacketStateSuccess copyWith({
    List<ShipmentAuditEpacket>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return HandleGetAuditEpacketStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetAuditEpacketStateFailure extends HandleGetAuditEpacketState {
  final String message;

  const HandleGetAuditEpacketStateFailure({required this.message});

  HandleGetAuditEpacketStateFailure copyWith({String? message}) {
    return HandleGetAuditEpacketStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class DetailsAuditEpacketState extends Equatable {
  const DetailsAuditEpacketState();
  @override
  List<Object?> get props => [];
}

class DetailsAuditEpacketStateInitial extends DetailsAuditEpacketState {}

class DetailsAuditEpacketStateLoading extends DetailsAuditEpacketState {}

class DetailsAuditEpacketStateSuccess extends DetailsAuditEpacketState {
  final DetailsShipmentModel detailsShipmentModel;
  final bool isMoreDetail; // Thêm biến này để xác định loại dialog

  const DetailsAuditEpacketStateSuccess({
    required this.detailsShipmentModel,
    required this.isMoreDetail, // Bắt buộc truyền vào
  });

  DetailsAuditEpacketStateSuccess copyWith({
    DetailsShipmentModel? detailsShipmentModel,
    bool? isMoreDetail,
  }) {
    return DetailsAuditEpacketStateSuccess(
      detailsShipmentModel: detailsShipmentModel ?? this.detailsShipmentModel,
      isMoreDetail: isMoreDetail ?? this.isMoreDetail, // Copy lại giá trị
    );
  }

  @override
  List<Object?> get props => [detailsShipmentModel, isMoreDetail];
}

class DetailsAuditEpacketStateFailure extends DetailsAuditEpacketState {
  final String message;

  const DetailsAuditEpacketStateFailure({required this.message});

  DetailsAuditEpacketStateFailure copyWith({String? message}) {
    return DetailsAuditEpacketStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class UpdateNoteAuditEpacketState extends Equatable {
  const UpdateNoteAuditEpacketState();
  @override
  List<Object?> get props => [];
}

class UpdateNoteAuditEpacketStateInitial extends UpdateNoteAuditEpacketState {}

class UpdateNoteAuditEpacketStateLoading extends UpdateNoteAuditEpacketState {}

class UpdateNoteAuditEpacketStateSuccess extends UpdateNoteAuditEpacketState {
  final String message;

  const UpdateNoteAuditEpacketStateSuccess({required this.message});

  UpdateNoteAuditEpacketStateSuccess copyWith({String? message}) {
    return UpdateNoteAuditEpacketStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class UpdateNoteAuditEpacketStateFailure extends UpdateNoteAuditEpacketState {
  final String message;

  const UpdateNoteAuditEpacketStateFailure({required this.message});

  UpdateNoteAuditEpacketStateFailure copyWith({String? message}) {
    return UpdateNoteAuditEpacketStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
