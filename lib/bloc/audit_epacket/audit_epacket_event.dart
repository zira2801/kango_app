part of 'audit_epacket_bloc.dart';

abstract class AuditEpacketEvent extends Equatable {
  const AuditEpacketEvent();

  @override
  List<Object?> get props => [];
}

class FetchListAuditEpacket extends AuditEpacketEvent {
  final String? startDate;
  final String? endDate;
  final int? shipmentBranchId;
  final int? shipmentServiceId;
  final int? shipmentStatus;
  final int? shipmentStatusPayment;
  final String? keywords;
  final String filterBy;

  const FetchListAuditEpacket({
    this.startDate,
    this.endDate,
    this.shipmentBranchId,
    this.shipmentServiceId,
    this.shipmentStatus,
    this.shipmentStatusPayment,
    this.keywords,
    required this.filterBy,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        shipmentBranchId,
        shipmentServiceId,
        shipmentStatus,
        shipmentStatusPayment,
        keywords,
        filterBy,
      ];
}

class LoadMoreListAuditEpacket extends AuditEpacketEvent {
  final String? startDate;
  final String? endDate;
  final int? shipmentBranchId;
  final int? shipmentServiceId;
  final int? shipmentStatus;
  final int? shipmentStatusPayment;
  final String? keywords;
  final String filterBy;

  const LoadMoreListAuditEpacket({
    this.startDate,
    this.endDate,
    this.shipmentBranchId,
    this.shipmentServiceId,
    this.shipmentStatus,
    this.shipmentStatusPayment,
    this.keywords,
    required this.filterBy,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        shipmentBranchId,
        shipmentServiceId,
        shipmentStatus,
        shipmentStatusPayment,
        keywords,
        filterBy,
      ];
}

abstract class DetailsAuditEpacketEvent extends Equatable {
  const DetailsAuditEpacketEvent();

  @override
  List<Object?> get props => [];
}

class HanldeDetailsAuditEpacket extends DetailsAuditEpacketEvent {
  final String? shipmentCode;
  final bool? isMoreDetail; // Thêm biến này để phân biệt loại dialog

  const HanldeDetailsAuditEpacket(
      {required this.shipmentCode, this.isMoreDetail});

  @override
  List<Object?> get props => [shipmentCode];
}

abstract class UpdateAuditEpacketEvent extends Equatable {
  const UpdateAuditEpacketEvent();

  @override
  List<Object?> get props => [];
}

class HandleUpdateAuditEpacket extends UpdateAuditEpacketEvent {
  final String shipmentCode;
  final String shipmentNote;

  const HandleUpdateAuditEpacket({
    required this.shipmentCode,
    required this.shipmentNote,
  });

  @override
  List<Object?> get props => [shipmentCode, shipmentNote];
}
